--[[
	Module to avoid too long concatentaions of {{PAGESINCATEGORY}}, #expr and formatnum in the
	table summarizing the articles and their levels in Wikivoyage.
	Maintainers:		User:Nastoshka
	Version:			1.0.0
	Last updated:		2024-02-17
]]


local p = {}

-- --------------------------------  SETUP VARIABLES ------------------------------------

-- Setup variables
local destinations = {"Distretto", "Città", "Regione nazionale", "Regione continentale", "Stato", "Continente", "Parco", "Monte", "Sito archeologico", "Massa d'acqua"}
local thematicArticleType = {"Aeroporto", "Frasario", "Itinerario", "Sentiero", "Tematica"}
local levels = {'Abbozzi', 'Articoli usabili', 'Guide', 'Articoli in vetrina', 'Articoli senza livello'}


-- --------------------------------  AUX FUNCTIONS ------------------------------------

local function _categoryExists(catName)
    local title = mw.title.new('Category:' .. catName)
    return title and title.exists or false
end

local function getCategoryCount(categoryName, flag)
    return mw.site.stats.pagesInCategory(categoryName, flag or 'pages')
end


-- --------------------------------  CALC SUM AND ARTICLE COUNTS ------------------------------------


-- ----------- TOTALS AND SUBTOTALS -------------------------

local function calcSummary(articleTypes, level)
    local sum = 0
    for _, articleType in ipairs(articleTypes) do
        local catName = articleType .. (level and " - " .. level or "")
        if _categoryExists(catName) then
            sum = sum + getCategoryCount(catName, "pages")
        end
    end
    return sum
end

function p.totalDestinations()
    local sum = calcSummary(destinations,nil) -- all levels
    return mw.language.getContentLanguage():formatNum(sum)
end

function p.totalDestinationsByType(frame)
    local level = frame.args[1]
	if not level or level == '' then
        error("Per il calcolo delle somme per livello è necessario inserire il parametro con il livello desiderato.")
    end

    local sum = calcSummary(destinations,level)
    return mw.language.getContentLanguage():formatNum(sum)
end


function p.totalThematicArticles()
    -- Handling Frasari e Tematiche (purtroppo il nome delle categorie non è consistente qui
    -- Per i livelli abbiamo come dapertutto "Tematica - Abbozzi",  "Tematica - Guide"...
    -- ma per la categoria generale i nomi sono "Frasari" e "Tematiche turistiche"
    local sum = calcSummary(thematicArticleType,nil) +
                getCategoryCount("Frasari", "pages") +
                getCategoryCount("Tematiche turistiche", "pages")

    return mw.language.getContentLanguage():formatNum(sum)
end

function p.totalThematicArticlesByType(frame)

	local level = frame.args[1]
	if not level or level == '' then
        error("Per il calcolo delle somme per livello è necessario inserire il parametro con il livello desiderato.")
    end
    local sum = calcSummary(thematicArticleType,level)
    mw.log(sum)
    return mw.language.getContentLanguage():formatNum(sum)
end

-- ----------- PERCENTAGES FOR THE COLORED BARS -------------------------

function p.percentagePerArticleType(frame)
	local articleType = frame.args["type"]
    local level = frame.args["level"]
    local parentCat = frame.args["parentCat"] or articleType -- per i casi in cui la categoria senza livello differisca nel nome da quelle con i livelli
    local percentage = "0"

	if not level or not articleType or level == '' or articleType == '' then
        error("I parametri 'type' e 'level' sono obbligatori.")
        return percentage
    end

    if not _categoryExists(parentCat) then
        error("La categoria " .. parentCat .. " non esiste.")
        return percentage
    end

	local total = getCategoryCount(parentCat, "pages")
    local catName = articleType .. " - " .. level
    if _categoryExists(catName) then
    	local count = getCategoryCount(catName,"pages")
        local percentage = count/total*100
        percentage = string.format("%.3f", percentage)
    end

    return percentage
end

return p

--Debugging:
--         =p.totalThematicArticlesByType(mw.getCurrentFrame():newChild{title="Module:StatsArticoli",args={}})
--         =p.percentagePerArticleType(mw.getCurrentFrame():newChild{title="Module:StatsArticoli",args={type="Città", level="Abbozzi"}})
