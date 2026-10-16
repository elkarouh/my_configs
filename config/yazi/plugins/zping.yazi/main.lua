local OUT = "/tmp/yazi-zping-input"
local SCRIPT = os.getenv("HOME") .. "/.config/yazi/plugins/zping.yazi/prompt.sh"

return {
  entry = function(self, job)
    if job.args and job.args[1] == "finish" then
      local f = io.open(OUT, "r")
      local value = f and f:read("*a") or ""
      if f then f:close() end
      os.remove(OUT)
      ya.notify({ title = "zping", content = "value=" .. value, timeout = 5, level = "info" })
    else
      ya.emit("shell", {
        string.format("sh %s %s; ya emit plugin zping finish", SCRIPT, OUT),
        block = true,
      })
    end
  end,
}
