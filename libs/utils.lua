local open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
function open_url(url)
    if not open_cmd then
        if package.config:sub(1,1) == '\\' then -- windows
            open_cmd = function(url)
                -- Should work on anything since (and including) win'95
                os.execute(string.format('start "%s"', url))
            end
        -- the only systems left should understand uname...
        -- OSX/Darwin
        elseif string.gsub(io.popen("uname -s"):read'*a', "\n", "") == "Darwin" then
            open_cmd = function(url)
                -- I cannot test, but this should work on modern Macs.
                os.execute(string.format('open "%s"', url))
            end
        else -- that ought to only leave Linux
            open_cmd = function(url)
                -- should work on X-based distros.
                os.execute(string.format('xdg-open "%s"', url))
            end
        end
    end

    open_cmd(url)
end

local exports = {}
exports.open_url = open_url
return exports
