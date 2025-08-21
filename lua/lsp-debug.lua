-- LSP Debug Helper Functions
-- This file provides additional debugging utilities for LSP issues

local M = {}

-- Function to check if required LSP servers are installed
function M.check_server_installation()
    local mason_registry = require("mason-registry")
    local servers = { "lua_ls", "cssls", "html", "ts_ls", "jsonls", "eslint" }
    
    local status = {}
    for _, server in ipairs(servers) do
        local package = mason_registry.get_package(server)
        status[server] = package:is_installed()
    end
    
    local message = "LSP Server Installation Status:\n"
    for server, installed in pairs(status) do
        local icon = installed and "✅" or "❌"
        message = message .. string.format("%s %s: %s\n", icon, server, installed and "Installed" or "Not installed")
    end
    
    vim.notify(message, vim.log.levels.INFO)
    return status
end

-- Function to force reinstall a problematic server
function M.reinstall_server(server_name)
    local mason_registry = require("mason-registry")
    
    if not mason_registry.has_package(server_name) then
        vim.notify("Server '" .. server_name .. "' not found in Mason registry", vim.log.levels.ERROR)
        return
    end
    
    local package = mason_registry.get_package(server_name)
    
    vim.notify("Reinstalling " .. server_name .. "...", vim.log.levels.INFO)
    
    if package:is_installed() then
        package:uninstall():once("closed", function()
            vim.defer_fn(function()
                package:install():once("closed", function()
                    vim.notify(server_name .. " reinstalled successfully!", vim.log.levels.INFO)
                end)
            end, 1000)
        end)
    else
        package:install():once("closed", function()
            vim.notify(server_name .. " installed successfully!", vim.log.levels.INFO)
        end)
    end
end

-- Function to create TypeScript project files for testing
function M.create_test_project()
    local test_dir = vim.fn.getcwd() .. "/lsp-test"
    
    -- Create test directory if it doesn't exist
    vim.fn.mkdir(test_dir, "p")
    
    -- Create package.json
    local package_json = {
        name = "lsp-test",
        version = "1.0.0",
        devDependencies = {
            ["@types/node"] = "^20.0.0",
            typescript = "^5.0.0"
        }
    }
    
    local package_content = vim.fn.json_encode(package_json)
    vim.fn.writefile(vim.split(package_content, "\n"), test_dir .. "/package.json")
    
    -- Create tsconfig.json
    local tsconfig = {
        compilerOptions = {
            target = "ES2020",
            module = "commonjs",
            strict = true,
            esModuleInterop = true,
            skipLibCheck = true,
            forceConsistentCasingInFileNames = true
        },
        include = { "*.ts", "*.js" },
        exclude = { "node_modules" }
    }
    
    local tsconfig_content = vim.fn.json_encode(tsconfig)
    vim.fn.writefile(vim.split(tsconfig_content, "\n"), test_dir .. "/tsconfig.json")
    
    -- Create test TypeScript file
    local ts_content = [[
interface User {
    id: number;
    name: string;
    email?: string;
}

function greetUser(user: User): string {
    return `Hello, ${user.name}!`;
}

const testUser: User = {
    id: 1,
    name: "Test User",
    email: "test@example.com"
};

console.log(greetUser(testUser));
]]
    
    vim.fn.writefile(vim.split(ts_content, "\n"), test_dir .. "/test.ts")
    
    vim.notify("Test TypeScript project created at: " .. test_dir, vim.log.levels.INFO)
    vim.notify("Open test.ts to verify LSP functionality", vim.log.levels.INFO)
    
    return test_dir
end

-- Function to diagnose LSP attachment issues
function M.diagnose_attachment_issues()
    local current_buf = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[current_buf].filetype
    local filename = vim.api.nvim_buf_get_name(current_buf)
    
    local diagnosis = {}
    diagnosis.buffer_info = {
        buffer = current_buf,
        filetype = filetype,
        filename = filename,
    }
    
    -- Check attached clients
    local clients = vim.lsp.get_clients({ bufnr = current_buf })
    diagnosis.attached_clients = {}
    for _, client in ipairs(clients) do
        table.insert(diagnosis.attached_clients, {
            name = client.name,
            id = client.id,
            root_dir = client.config.root_dir,
            stopped = client.is_stopped(),
        })
    end
    
    -- Check if servers should be attached for this filetype
    local expected_servers = {}
    if filetype == "typescript" or filetype == "javascript" or filetype == "typescriptreact" or filetype == "javascriptreact" then
        table.insert(expected_servers, "ts_ls")
        table.insert(expected_servers, "eslint")
    elseif filetype == "lua" then
        table.insert(expected_servers, "lua_ls")
    elseif filetype == "html" then
        table.insert(expected_servers, "html")
    elseif filetype == "css" then
        table.insert(expected_servers, "cssls")
    elseif filetype == "json" then
        table.insert(expected_servers, "jsonls")
    end
    
    diagnosis.expected_servers = expected_servers
    diagnosis.missing_servers = {}
    
    for _, expected in ipairs(expected_servers) do
        local found = false
        for _, client in ipairs(clients) do
            if client.name == expected then
                found = true
                break
            end
        end
        if not found then
            table.insert(diagnosis.missing_servers, expected)
        end
    end
    
    -- Format diagnosis report
    local report = string.format([[
🔍 LSP Attachment Diagnosis Report
=====================================

Buffer Info:
  - Buffer ID: %d
  - Filetype: %s
  - Filename: %s

Attached Clients (%d):]], 
        diagnosis.buffer_info.buffer,
        diagnosis.buffer_info.filetype,
        diagnosis.buffer_info.filename,
        #diagnosis.attached_clients
    )
    
    if #diagnosis.attached_clients == 0 then
        report = report .. "\n  ❌ No LSP clients attached"
    else
        for _, client in ipairs(diagnosis.attached_clients) do
            local status = client.stopped and "❌ Stopped" or "✅ Active"
            report = report .. string.format("\n  %s %s (ID: %d)", status, client.name, client.id)
            if client.root_dir then
                report = report .. string.format("\n    Root: %s", client.root_dir)
            end
        end
    end
    
    report = report .. string.format("\n\nExpected Servers (%d): %s", 
        #diagnosis.expected_servers, 
        table.concat(diagnosis.expected_servers, ", ")
    )
    
    if #diagnosis.missing_servers > 0 then
        report = report .. string.format("\n\n⚠️  Missing Servers (%d): %s", 
            #diagnosis.missing_servers,
            table.concat(diagnosis.missing_servers, ", ")
        )
        report = report .. "\n\n💡 Suggestions:"
        report = report .. "\n  - Try :LspStart <server_name>"
        report = report .. "\n  - Check :Mason for server installation"
        report = report .. "\n  - Use <leader>lR to restart all servers"
    else
        report = report .. "\n\n✅ All expected servers are attached!"
    end
    
    vim.notify(report, vim.log.levels.INFO)
    
    return diagnosis
end

return M