--Just put this in StarterGui!

local module = {}

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = script.Parent.Parent

local Camera = Workspace.CurrentCamera

local TweenInformation1 = TweenInfo.new(
	1,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TweenInformation2 = TweenInfo.new(
	.5,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TweenInformation3 = TweenInfo.new(
	3,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	2
)

function module.LoopSound(SoundId, TweenInformation)
	--MusicId is required (this is the ID of the music being played)
	--TweenInformation is optional
	if type(SoundId) ~= "number" and type(SoundId) ~= "string" then
		warn("Input AssetId of music into the LoopMusic function")
	else
		local Sound = Instance.new("Sound")
		Sound.Parent = LocalPlayer.PlayerGui
		Sound.SoundId = "rbxassetid://".. tostring(SoundId)
		Sound.Name = "LoopedSound"
		Sound.Volume = 0
		Sound.Looped = true
		Sound:Play()
		
		if TweenInformation == nil then
			local MusicTween = TweenService:Create(Sound,TweenInformation3,{Volume = .3})
			MusicTween:Play()
		else
			local MusicTween = TweenService:Create(Sound,TweenInformation,{Volume = .3})
			MusicTween:Play()
		end
		
		return Sound
	end
end

function module.MultiCameraSystem(PartFolder, CameraTweenInformation, ColorCorrectionFadeInformation) --This should be called as a coroutine.create
	--CameraTweenInformation, CCFadeInformation, and CCTWeenInformation are optional but MUST be put as false if they aren't being used
	--If no ColorCorrectionFadeInformation is inputted, there will be no CC fade at all
	--Format ColorCorrectionFadeInformation as a table like {TintColor = , TweenInformation = }
	if PartFolder:FindFirstChild("Initial") == false and PartFolder:FindFirstChild("Final") == false then
		warn("PartFolder incorrectly configured")
	else
		--Set up
		local CamTweenInfo
		local CCFadeInfo
		local CameraTransitionCC
		
		--Set up camera tween information
		if CameraTweenInformation ~= false then
			if type(CameraTweenInformation) == "userdata" then
				CamTweenInfo = CameraTweenInformation
			else
				warn("CameraTweenInformation inputted incorrectly, using defaults")
				CamTweenInfo = TweenInfo.new(
					20,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					0,
					false,
					0
				)
			end
		else
			CamTweenInfo = TweenInfo.new(
				20,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.Out,
				0,
				false,
				0
			)
		end
		
		--Sets up CC fade tween information if any is inputted
		if ColorCorrectionFadeInformation ~= false then
			if ColorCorrectionFadeInformation.TweenInformation ~= nil and type(ColorCorrectionFadeInformation.TweenInformation) == "userdata" then
				CCFadeInfo = ColorCorrectionFadeInformation.TweenInformation
			else
				warn("ColorCorrectionFadeInformation.TweenInformation inputted incorrectly, using defaults")
				CCFadeInfo = TweenInfo.new(
					1.5,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out,
					0,
					true,
					0
				)
			end
		end

		--Sets transition delay
		local TransitionDelay = 0
		
		if CCFadeInfo ~= nil then
			TransitionDelay = CamTweenInfo.Time + CCFadeInfo.Time
			
			CameraTransitionCC = Instance.new("ColorCorrectionEffect")
			CameraTransitionCC.Name = "CameraTransitionCC"
			CameraTransitionCC.Parent = Lighting
		end
		
		--Action
		local NumberOfCameraValues = table.getn(PartFolder.Initial:GetChildren())
		local CurrentCameraValue = 0 --This will start it at the first CFrame element
		
		Camera.CameraType = Enum.CameraType.Scriptable
		
		local CurrentCameraTween = Instance.new("ObjectValue")
		CurrentCameraTween.Name = "CurrentCameraTween"
		CurrentCameraTween.Parent = LocalPlayer.PlayerGui
		
		while true do
			if (CurrentCameraValue + 1) <= NumberOfCameraValues then
				CurrentCameraValue = CurrentCameraValue + 1
			else
				CurrentCameraValue = 1
			end
			
			Camera.CameraSubject = PartFolder.Initial[tostring(CurrentCameraValue)]
			Camera.CFrame = PartFolder.Initial[tostring(CurrentCameraValue)].CFrame
			
			--Move the camera from Initial to Final
			local Tween = TweenService:Create(Camera, CameraTweenInformation, {CFrame = PartFolder.Final[tostring(CurrentCameraValue)].CFrame})
			Tween:Play()
			CurrentCameraTween.Value = Tween
			
			Tween.Completed:Connect(function()
				if ColorCorrectionFadeInformation ~= false then
					local Tween2 = TweenService:Create(CameraTransitionCC, CCFadeInfo, {TintColor = ColorCorrectionFadeInformation.TintColor})
					Tween2:Play()
					CurrentCameraTween.Value = Tween2
				end
			end)
			wait(TransitionDelay)
		end
	end
end

function module.StopMultiCameraSystem()
	local CurrentCameraTween = LocalPlayer.PlayerGui:FindFirstChild("CurrentCameraTween")
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
	CurrentCameraTween.Value:Cancel()
	CurrentCameraTween:Destroy()
end

return module
