ProvinatusSocket = {}

function ProvinatusSocket:Initialize()
  self.LGS = LibStub("LibGroupSocket")
  self.MessageType = self.LGS.MESSAGE_TYPE_RESOURCES
  self.LGS:RegisterHandler(self.MessageType, 1)
  self.LGS:RegisterCallback(self.MessageType, ProvinatusUltimateHandler.HandleData)
end
