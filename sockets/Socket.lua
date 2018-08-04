ProvinatusSocket = {}

function ProvinatusSocket:Initialize()
  self.LGS = LibStub("LibGroupSocket")
  self:RegisterHandler()
  self:RegisterCallback()
end

function ProvinatusSocket:RegisterHandler()
  self.LGS:RegisterHandler(3, 1)
end

function ProvinatusSocket:RegisterCallback()
  self.LGS:RegisterCallback(3, self:Callback())
end

function ProvinatusSocket:Callback(UnitTag, Data)
  return function()
    d(UnitTag)
    d(Data)
  end
end

SLASH_COMMANDS["/foo"] = function()
  d(ProvinatusSocket.LGS:Send("Absolute Unit", {[1] = 1}))
end
