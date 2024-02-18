--[[
	Module to avoid too long concatentaions of {{PAGESINCATEGORY}}, #expr and formatnum in the
	table summarizing the articles and their levels in Wikivoyage.
	Maintainers:		User:Nastoshka
	Version:			1.0.0
	Last updated:		2024-02-17

-- Debugging examples:
		   =p.totalDestinations(mw.getCurrentFrame():newChild{title="Module:StatsArticoli",args={}})
--         ==p.totalDestinationsByLevel(mw.getCurrentFrame():newChild{title="Module:StatsArticoli",args={livello="Articoli usabili"}})
--         =p.percentagePerArticleType(mw.getCurrentFrame():newChild{title="Module:StatsArticoli",args={tipo="Città", livello="Abbozzi"}})
]]


local p = {}

-- --------------------------------  SETUP VARIABLES ------------------------------------

-- Setup variables
local destinations = {"Distretto", "Città", "Regione nazionale", "Regione continentale", "Stato", "Continente", "Parco", "Monte", "Sito archeologico", "Massa d'acqua"}
local thematicTypes = {"Aeroporto", "Frasario", "Itinerario", "Sentiero", "Tematica"}
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

function p.totalDestinationsByLevel(frame)
    local level = frame.args["livello"]
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
    local sum = calcSummary(thematicTypes,nil) +
                getCategoryCount("Frasari", "pages") +
                getCategoryCount("Tematiche turistiche", "pages")

    return mw.language.getContentLanguage():formatNum(sum)
end

function p.totalThematicArticlesByLevel(frame)

	local level = frame.args["livello"]
	if not level or level == '' then
        error("Per il calcolo delle somme per livello è necessario inserire il parametro con il livello desiderato.")
    end
    local sum = calcSummary(thematicTypes,level)
    return mw.language.getContentLanguage():formatNum(sum)
end

function p.totalDisambiguation()
    local pages = getCategoryCount("Disambigue", "pages")
    return mw.language.getContentLanguage():formatNum(pages)
end

function p.totalPortals()
    local portals = getCategoryCount("Portali", "pages")
    return mw.language.getContentLanguage():formatNum(portals)
end

function p.totalUNESCO()
    local unesco = getCategoryCount("Liste dei patrimoni mondiali dell'umanità", "pages")
    return mw.language.getContentLanguage():formatNum(unesco)
end

function p._grandTotal()
    local total_destinations = calcSummary(destinations,nil)
    local total_thematic = calcSummary(thematicTypes,nil) +
                getCategoryCount("Frasari", "pages") +
                getCategoryCount("Tematiche turistiche", "pages")

    local total_disambiguation = getCategoryCount("Disambigue", "pages")
    local total_portals = getCategoryCount("Portali", "pages")
    local total_unesco = getCategoryCount("Liste dei patrimoni mondiali dell'umanità", "pages")

    local sum = total_destinations + total_thematic + total_disambiguation + total_portals + total_unesco
    return sum
end

function p.grandTotal()
    local sum = p._grandTotal()
    return mw.language.getContentLanguage():formatNum(sum)
end

function p.totalUncategorized()
    local uncategorized = mw.site.stats.articles - p._grandTotal()
    return mw.language.getContentLanguage():formatNum(uncategorized)
end


-- ----------- PERCENTAGES FOR THE COLORED BARS -------------------------

function p.percentagePerArticleType(frame)
	local articleType = frame.args["tipo"]
    local level = frame.args["livello"]
    local parentCat = frame.args["parent"] or articleType -- per i casi in cui la categoria senza livello differisca nel nome da quelle con i livelli
    local percentage = "0"

	if not level or not articleType or level == '' or articleType == '' then
        error("I parametri 'tipo' e 'livello' sono obbligatori.")
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
        percentage = count/total*100
        percentage = string.format("%.3f", percentage)
    end

    return percentage
end

function p.percentageByTypeAndLevel(frame)
    local type = frame.args["tipo"] -- "destinazioni" o "tematiche"
    local level = frame.args["livello"]
    local total = 0
    local subtotal = 0
    local percentage = "0"

    if not level or not type or level == '' or type == '' then
        error("I parametri 'tipo' e 'livello' sono obbligatori.")
        return percentage
    end

    if type == "destinazioni" then
        total = calcSummary(destinations,nil)
        subtotal = calcSummary(destinations,level)
    elseif type == "tematiche" then
        total = calcSummary(thematicTypes,nil)
        subtotal = calcSummary(thematicTypes,level)
    else
        error("Il parametro 'tipo' deve essere 'destinazioni' o 'tematiche'.")
        return percentage
    end

    if total > 0 then
        percentage = string.format("%.3f",  subtotal/total*100)
    end

    return percentage
end

return p
-- --------------------------------  END ------------------------------------