local require = require(script.Parent.loader).load(script)

local InputNames = require("InputNames")
local InputPlatforms = require("InputPlatforms")
local Signal = require("Signal")

export type InputName = InputNames.InputName

export type InputPlatform = InputPlatforms.InputPlatform

export type Input = Enum.UserInputState | InputObject

local InputSettings = {
	BUILD_OR_DELETE_INPUT = {
		PC = Enum.UserInputType.MouseButton1,
		CONSOLE = Enum.KeyCode.ButtonX,
		MOBILE = false,
	},
	ROTATE_BUILD_INPUT = {
		PC = Enum.KeyCode.R,
		CONSOLE = Enum.KeyCode.ButtonR1,
		MOBILE = true,
	},
	DELETE_MODE_INPUT = {
		PC = Enum.KeyCode.C,
		CONSOLE = Enum.KeyCode.ButtonB,
		MOBILE = false,
	},
	BLOCK_1_INPUT = {
		PC = Enum.KeyCode.One,
		CONSOLE = Enum.KeyCode.One,
		MOBILE = false,
	},
	BLOCK_2_INPUT = {
		PC = Enum.KeyCode.Two,
		CONSOLE = Enum.KeyCode.Two,
		MOBILE = false,
	},
	BLOCK_3_INPUT = {
		PC = Enum.KeyCode.Three,
		CONSOLE = Enum.KeyCode.Three,
		MOBILE = false,
	},
	BLOCK_4_INPUT = {
		PC = Enum.KeyCode.Four,
		CONSOLE = Enum.KeyCode.Four,
		MOBILE = false,
	},
	BLOCK_5_INPUT = {
		PC = Enum.KeyCode.Five,
		CONSOLE = Enum.KeyCode.Five,
		MOBILE = false,
	},

	Changed = Signal.new(),
}

function InputSettings:ChangeInput(inputToChangeName: InputName, inputToChangePlatform: InputPlatform, newInput: Input)
	InputSettings[inputToChangeName][inputToChangePlatform] = newInput

	InputSettings.Changed:Fire(newInput, inputToChangeName, inputToChangePlatform)

	return InputSettings[inputToChangeName][inputToChangePlatform]
end

return InputSettings
