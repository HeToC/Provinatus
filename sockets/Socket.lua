ProvinatusSocket = {}

local function Callback(UnitTag, Data)
  d("Yay")
  d(UnitTag)
  d(Data)
end

function ProvinatusSocket:Initialize()
  self.LGS = LibStub("LibGroupSocket")
  self.MessageType = self.LGS.MESSAGE_TYPE_RESOURCES
  self.LGS:RegisterHandler(self.MessageType, 1)
  self.LGS:RegisterCallback(self.MessageType, Callback)
end

SLASH_COMMANDS["/foo"] = function()
  d(ProvinatusSocket.LGS:Send(ProvinatusSocket.MessageType, {[1] = 1}))
end
