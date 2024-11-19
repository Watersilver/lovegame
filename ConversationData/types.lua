-- TODO: Dialogues should track their own global variables that get saved in save file for simplicity

-- TODO: system to pause dialogue running until something happens at which point it can resume

---@class GameObject
---@field x? number
---@field y? number
---@field xstart? number
---@field ystart? number

---@class ConversationObject: GameObject
---@field currentNode DlgNode
---@field data ConversationData

---@class DlgOptions
-- number of seconds between each letter
---@field delay? number
---@field letterSound? love.Source | 'none' | fun(convo: ConversationObject): love.Source
---@field immobilizePlayer? boolean
---@field color? string
---@field facingRequired? 'up' | 'down' | 'left' | 'right'
---@field proximityRequired? DlgParticipantId[] | 'none'
---@field damageDoesntInterrupt? boolean
---@field forceBubblePosition? 'up' | 'down'
---@field staysOnScreen? boolean
---@field noSpeechBubbleTail? boolean
---@field onInterrupt? DlgNodeInterruptIdGetter
---@field uninterruptible? boolean

---@class ConversationData
---@field id ConversationId
---@field nodes DlgNode[]
---@field choices? DlgChoice[]
---@field participants DlgParticipantId[] If empty parent instance will speak the dlg
---@field options? DlgOptions
---@field startNodeData DlgNextNodeDataGetter
---@field activators? DlgParticipantId[] | 'none'

---@class DlgNode
---@field id DlgNodeId
---@field text TextGetter
---@field autoProgress? boolean
---@field onEndDelay? number | fun(convo: ConversationObject): number
---@field onEnd? DlgNextNodeDataGetter
---@field onEvent? fun(convo: ConversationObject, event: string): DlgNextNodeDataGetter
-- Default is first participant
---@field anchor? DlgParticipantId
---@field options? DlgOptions
---@field choices? (DlgChoice | DlgChoiceId)[]

---@class DlgChoice
---@field id DlgChoiceId
---@field available? fun(convo: ConversationObject): boolean
---@field text ChoiceGetter
---@field onChoose DlgNextNodeDataGetter

---@alias ConversationId string
---@alias DlgNodeId string
---@alias DlgNextNodeData {id?: DlgNodeId, keepConversationAlive?: {keepTextBubbleAlive?: boolean}, events?: string[]}
---@alias DlgNextNodeDataGetter DlgNextNodeData | fun(convo: ConversationObject): DlgNextNodeData
---@alias DlgNodeInterruptIdGetter DlgNodeId | fun(convo: ConversationObject, reason: string): DlgNodeId
---@alias DlgChoiceId string
---@alias DlgParticipantId string

-- Represents the text of some dialogue node
---@alias TextGetter string | fun(convo: ConversationObject): string
---@alias ChoiceGetter string | fun(convo: ConversationObject): string
