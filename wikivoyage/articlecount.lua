local p = {}

-- --------------------------------  SETUP VARIABLES ------------------------------------

-- Articoli "Destinazioni" per tipo
local destinations = { "Distretto", "Città", "Regione nazionale", "Regione continentale",
	"Stato", "Continente", "Parco", "Monte", "Sito archeologico", "Massa d'acqua" }
local thematicArticleType = {"Aeroporto", "Frasario", "Itinerario", "Sentiero", "Tematica"}
local servicePages = {"Patrimoni Mondiali dell'Umanità", "Portali", "Disambigue"}

-- Livelli articolo
local levels =  {'Abbozzi', 'Articoli usabili', 'Guide', 'Articoli in vetrina', 'Articoli senza livello'}

-- --------------------------------  AUX FUNCTIONS ------------------------------------

local function is_defined(s)
	if s and s ~= '' then return s end
	return nil
end

local function _categoryExists(catName)
    local title = mw.title.new('Category:' .. catName)
    return title and title.exists or false
end

local function getCategoryCount(categoryName, flag)
	local flag = flag or 'pages'
    return mw.site.stats.pagesInCategory(categoryName, flag)
end

-- --------------------------------  CALC SUM AND ARTICLE COUNTS ------------------------------------


-- ----------- TOTALS AND SUBTOTALS -------------------------
function p.totalDestinations()
    local sum = 0

    for _, articleType in ipairs(destinations) do
        if _categoryExists(articleType) then
        	sum = sum + getCategoryCount(articleType)
        end
    end

    return mw.language.getContentLanguage():formatNum(sum)
end

function p.totalDestinationsByType(frame)

	if not is_defined(frame.args[1]) then
		error("Per il calcolo delle somme per livello è necessario inserire il parametro con il livello desiderato")
	end

	local level = frame.args[1]
    local sum = 0

    for _, articleType in ipairs(destinations) do
    	local catName = articleType .. " - " .. level
        if _categoryExists(catName) then
        	sum = sum + getCategoryCount(catName)
        end
    end

    return mw.language.getContentLanguage():formatNum(sum)
end


function p.totalThematicArticles()
    local sum = 0

    for _, articleType in ipairs(thematicArticleType) do
        if _categoryExists(articleType) then
        	sum = sum + getCategoryCount(articleType)
        end
    end

    -- Handling Frasari e Tematiche (purtroppo il nome delle categorie non è consistente qui
    -- Per i livelli abbiamo come dapertutto "Tematica - Abbozzi",  "Tematica - Guide"...
    -- ma per la categoria generale i nomi sono "Frasari" e "Tematiche turistiche"
    sum = sum + getCategoryCount("Frasari")
    sum = sum + getCategoryCount("Tematiche turistiche")

    return mw.language.getContentLanguage():formatNum(sum)
end

function p.totalThematicArticlesByType(frame)

	if not is_defined(frame.args[1]) then
		error("Per il calcolo delle somme per livello è necessario inserire il parametro con il livello desiderato")
	end

	local level = frame.args[1]
    local sum = 0

    for _, articleType in ipairs(thematicArticleType) do
    	local catName = articleType .. " - " .. level
        if _categoryExists(catName) then
        	sum = sum + getCategoryCount(catName)
        end
    end

    return mw.language.getContentLanguage():formatNum(sum)
end

-- ----------- PERCENTAGES FOR THE COLORED BARS -------------------------

function p.percentagePerArticleType(frame)
	local args = frame.args
	local articleType = args["type"]
	local level = args["level"]
	local parentCat = args["parentCat"] or articleType -- per i casi in cui la categoria senza livello differisca nel nome da quelle con i livelli

	if not is_defined(level) or not is_defined(articleType) then
		error("Controlla i parametri nella chiamata a percentagePerArticleType")
	end

	local total = getCategoryCount(parentCat, "pages")
    local catName = articleType .. " - " .. level
    if _categoryExists(catName) then
    	local count = getCategoryCount(catName,"pages")
        local percentage = count/total*100
        return math.floor(percentage)
    else
    	return 0
    end

end

return p