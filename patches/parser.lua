#!/usr/bin/env lua
local lpeg = require "lpeg"
local locale = lpeg.locale(lpeg);
local P, S, R, C, V = lpeg.P, lpeg.S, lpeg.R, lpeg.C, lpeg.V
local Cg, Cf, Ct = lpeg.Cg, lpeg.Cf, lpeg.Ct
local printf = function (...) io.write(string.format(...)) end

local space = S " \t"^1
local sspace = #P " "^1
local eol = S "\r\n\f"^1
local digit = R "09"
local letter = R ("az", "AZ")
local word = P(lpeg.alpha)^1
local token = S "[]"^-1
local escaped = P "\\\"" + P "\\\\" + P "\\b" + P "\\f" + P "\\n" + P "\\r" + P "\\t"
local qstring = P [["]] * (escaped + (1 - P [["]]))^0 * P [["]]
local sstring = P "'" * (escaped + P "\\'" + (1 - P "'"))^0 * P "'"
local comment = P "#" * (1 - S "\r\n\f")^0

local parameter = C(word + letter + digit + qstring + sstring)
local module = Cg(parameter * space * parameter) * eol
local attributes = Cg(space * parameter * space * parameter) * eol
local mtable = Cf(Ct[[]] * module^0, rawset)
local atable = Cf(Ct[[]] * attributes^0, rawset)



local sample = [=[
package vim
 action install
user ed
 action add
 home "/home/ed"
directory "/tmp/test space"
 action create
 mode 0755
file '/tmp/test quoted string'
 action create
 mode 0644
echo 1
  action run
]=]

local x=mtable:match(sample)
local y=atable:match(sample)

for a,b in pairs(x) do
    printf("module: %s\n", a)
    printf("arg: %s\n", b)
end
for a,b in pairs(y) do
    print(a,b)
end


