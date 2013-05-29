#!/usr/bin/env lua
local lpeg = require "lpeg"
local locale = lpeg.locale(lpeg);
local match = lpeg.match
local P, S, R = lpeg.P, lpeg.S, lpeg.R
local C, Cg = lpeg.C, lpeg.Cg
local printf = function (...) io.write(string.format(...)) end

local space = S" \t"^1
local tspace = S" \t"^0
local eol = S"\r\n\f"^1
local digit = R"09"
local letter = R("az", "AZ")
local word = P(lpeg.alnum)^1
local escaped = P"\\\"" + P"\\\\" + P"\\b" + P"\\f" + P"\\n" + P"\\r" + P"\\t"
local qstring = P[["]] * (escaped + (1-P[["]]))^0 * P[["]]
local sstring = P"'" * (escaped + P"\\'" + (1-P"'"))^0 * P"'"
local comment = P"#" * (1-S"\r\n\f")^0

sample = [[
emerge vim
  requires ed
  action install
user ed
  action add
  home "/home/ed"
directory "/tmp/test space"
  action create
  mode 0755
file '/tmp/test single quoted string'
  action create
  mode 0644

#test comment
#test multi-line comment
echo a
  action run
echo 1
  action run
echo '/tmp/test indention'
    action run

echo '/tmp/test trailing space'
  action run  
]]

function isfile(File)
    local _, f = pcall(io.open, File, 'r')
    if f == nil then return false end
    local _, _, code = f:read(1)
    f:close()
    if code == nil then return true end
    return false
end

function fopen(File)
    local _, f = pcall(io.open, File,'r')
    if not f then return nil,err end
    local str, err = f:read('*a')
    f:close()
    if not str then return nil,err end
    return str
end

function ismodule(Module)
    local cwd = os.getenv('PWD')
    local message = " does not appear to be a valid module!"
    assert(isfile(cwd.."/modules/"..Module), Module..message)
end

function isparameter(Module, Parameter)
    local cwd = os.getenv('PWD')
    local message = " does not appear to be a valid parameter!"
    local match = false
    local str = fopen(cwd.."/modules/"..Module)
    local x=str:match("#.*parameters.*=(.*)")
    local x=x.."requires" -- internal parameter
    for i in x:gmatch("%S+") do
        if i == Parameter then return end
    end
    assert(match, Parameter..message)
end

local capture = C(word + letter + digit + qstring + sstring)
local config={}
local module, arg=nil
for line in sample:gmatch('[^\f\r\n]+') do
    if line:find('^%w') then
        module, arg = Cg(capture*space*capture*tspace):match(line)
        config[#config+1]={}
        --print("=module:"..module,"=arg:"..arg)
    end
    if line:find('^%s+') then
        local parameter, value = Cg(space*capture*space*capture*tspace):match(line)
        --print("===parameter:"..parameter,"===value:"..value)
        config[#config][module.."\000"..arg.."\000"..parameter]=value
    end
end

-- tests
for K, V in ipairs(config) do
    print(K)
    for x, y in pairs(V) do
        --printf('%q \n %q \n', x, y)
        local module=x:match("(.*)%c.*%c.*")
        local arg=x:match(".*%c(.*)%c.*")
        local parameter=x:match(".*%c.*%c(.*)")
        print("module: "..module)
        ismodule(module)
        print("arg: "..arg)
        print("parameter: "..parameter)
        isparameter(module, parameter)
        print("value: "..y)
    end
end

