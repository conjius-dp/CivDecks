-- Open or refresh an existing browser tab on localhost:8060
-- Checks Chrome first, then Safari. Opens a new tab only if none found.

on findInChrome()
    try
        tell application "Google Chrome"
            repeat with w in windows
                repeat with t in tabs of w
                    if URL of t starts with "http://localhost:8060" then
                        reload t
                        return true
                    end if
                end repeat
            end repeat
        end tell
    end try
    return false
end findInChrome

on findInSafari()
    try
        tell application "Safari"
            repeat with w in windows
                repeat with t in tabs of w
                    if URL of t starts with "http://localhost:8060" then
                        do JavaScript "location.reload()" in t
                        return true
                    end if
                end repeat
            end repeat
        end tell
    end try
    return false
end findInSafari

if not findInChrome() then
    if not findInSafari() then
        do shell script "open http://localhost:8060/"
    end if
end if
