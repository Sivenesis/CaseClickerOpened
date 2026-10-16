local Language = {polish = 1, english = 2}
local languageFilenames = {
	[Language.english] = "english",
	[Language.polish] = "polish"
}
function Language.init()
	Language.set(Language.english)
end
function Language.set(lang)
	Lang = require("languages." .. languageFilenames[lang] .. "_core")
	Lang.achievements = require("languages." .. languageFilenames[lang] .. "_achievements")
	Lang.upgrades = require("languages." .. languageFilenames[lang] .. "_upgrades")
	if Achievements then
		AchievementManager.init()
	end
	if Menu then
		Menu.updateLanguageTexts()
		Menu.updateBalanceText()
	end
	if Game then
		composer.removeScene("scenes.missions")
	end
	if composer then
		composer.removeHidden(false)
	end
end
return Language
