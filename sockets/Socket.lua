ProvinatusSocket = {}

function ProvinatusSocket:Initialize()
  self.LGS = LibStub("LibGroupSocket")
  self.MessageType = 3
  self.LGS:RegisterHandler(self.MessageType, 1)
  self.LGS:RegisterCallback(self.MessageType, ProvinatusUltimateHandler.HandleData)
end
