--[[
	Source script:	https://it.wikivoyage.org/wiki/Modulo:Avviso
	Maintainer:		Andyrom75, Nastoshka
		v.1.0.0 -- Andyrom75 (novembre 2021)
		v.2.0.0 -- Nastoshka (gennaio 2024)
]]

-- --------------------------- Funzioni ausiliarie ---------------------------------------------

-- Meta funzione per impostare un valore di default per una tabella Lua
-- nel caso si tentasse l'accesso ad un parametro non esistente
-- Vedi: https://www.lua.org/pil/13.4.3.html
function setDefault (t, d)
  local mt = {__index = function () return d end}
  setmetatable(t, mt)
end

-- --------------------------- Costanti ---------------------------------------------

-- immagine per il banner di avviso
local IMAGE_PATHS = {
    importante = '[[File:Stop hand nuvola.svg|40px|link=]]',
    contenuto = '[[File:Emblem-important.svg|40px|link=]]',
    stile = '[[File:Broom icon.svg|40px|link=]]',
    statico = '[[File:Gnome globe current event.svg|40px|link=]]',
    struttura = '[[File:Merge-split-transwiki default.svg|40px|link=]]',
    avviso = '[[File:Info non-talk.png|40px|link=]]',
    disambigua = '[[File:Info non-talk.png|40px|link=]]',
    protezione = '[[File:Padlock.svg|40px|link=]]',
    disclaimer = '[[File:Nuvola_apps_important.svg|40px|link=]]',
    trasparente = '[[File:No image.svg|link=]]',
    -- vetrina = '[[File:Crystal Clear action bookmark silver and gold doubt.svg|40px|link=]]',
    default = '[[File:Info non-talk.png|40px|link=]]'
}
setDefault(IMAGE_PATHS, IMAGE_PATHS.default)

-- determina il css da usare e in alcuni casi categorizza (dipendentemente dal namespace)
local WARNING_TYPE = {
    importante = 'avviso-importante',
    contenuto = 'avviso-contenuto',
    stile = 'avviso-stile',
    statico = 'avviso-statico',
    struttura = 'avviso-struttura',
    avviso = 'avviso-informazioni',
    disambigua = 'avviso-disambigua hatnote',
    protezione = 'avviso-generico',
    disclaimer = 'avviso-disclaimer',
    default = 'avviso-informazioni'
}
setDefault(WARNING_TYPE, WARNING_TYPE.default)

local IMAGE_BOX_SIZE_DEFAULT = '52px'



-- --------------------------- Funzioni principali ---------------------------------------------

-- Stabilisci l'icona da usare a lato del testo
-- Se un'immagine è stata passata come parametro, prendi quella
-- altrimenti usa il tipo come fallback (se il tipo non esiste nell'array / table, usa il default)
-- stabilisci l'icona da usare a lato del testo
local function getWarningImage(args)
    -- se esplicitamente richiesto, non mostrare alcuna immagine
    if args['2'] == 'nessuna' or args.immagine == 'nessuna' then
        return '&nbsp;'
    end
    -- altrimenti analizza il parametro, come fallback usa il tipo di avviso per determinare l'immagine
    local passed_image = args['2'] or args.immagine

    if imageKey then
    	return '<div style="width:' .. (args.imageboxsize or IMAGE_BOX_SIZE_DEFAULT) .. ';">'
            .. passed_image
    end

    return '<div style="width:' .. (args.imageboxsize or IMAGE_BOX_SIZE_DEFAULT) .. ';">'
            .. IMAGE_PATHS[args.tipo]
end

local function get_right_image(args)
    local right_image = args['immagine a destra'] or false

    if not right_image then
        return ''
    end

    return '<div class="avviso-immaginedestra">'
        .. '<div style="width:' .. (args.imageboxsize or IMAGE_BOX_SIZE_DEFAULT) .. ';"> ' .. right_image .. ' </div>'
        .. '</div>'
end

local function getWarningText(args)
    local text = args['1'] or args.testo or ''
    return tostring(text)
end

local function getCategoryTag(args)
    local title_obj = mw.title.getCurrentTitle()

    local namespace =  title_obj.namespace
    local page_title = title_obj.text

    local should_be_categorized = args.tipo == 'avviso' or args.tipo == 'importante'

    if namespace == 8 then -- MediaWiki namespace
        return '[[Categoria:Messaggi di sistema con avviso|' .. page_title .. ']]'
    end

    if namespace == 0 and should_be_categorized then -- Main namespace, tipo avviso o importante
        return '[[Categoria:Articoli con avviso]]'
    end

    return '' -- Non categorizzare
end

-- --------------------------- Main logic ---------------------------------------------
local function generateWarningBox(frame)
    local args = frame.args

    -- raccogliamo i pezzi del puzzle
    local style = args.stile or ''
    local warningType = WARNING_TYPE[args.tipo]
    local warningImage = getWarningImage(args)
    local warningRightImage = get_right_image(args)
    local warningText = getWarningText(args)
    local categoryTag = getCategoryTag(args)

    -- e mettiamo insieme il tutto ;)
    local htmlOutput = {
        '<div style="' .. style .. '" class="plainlinks noprint avviso ambox ' .. warningType .. '">',
        '<div class="avviso-immagine mbox-image">',
        warningImage,
        '</div>',
        '</div>',
        '<div class="avviso-testo mbox-text-span" style="' .. (args['stile testo'] or '') .. '">',
        warningText,
        '</div>',
        warningRightImage,
        '</div>',
        categoryTag
    }
    -- mw.log('htmlOutput: ' .. table.concat(htmlOutput)) -- DEBUG
    return table.concat(htmlOutput)
end

-- --------------------------- Interfaccia del modulo ---------------------------------------------

local p = {} -- package to be exported

-- per la differenza tra frame e frame:getParent() vedi
-- - https://en.wikipedia.org/wiki/Help:Lua_for_beginners#Parent_frame
-- - https://it.wikivoyage.org/wiki/Modulo:Arguments/man
function p.avvisoTemplate(frame)
    return generateWarningBox(frame:getParent()) -- se invocato attraverso un template
end

function p.avviso(frame)
    return generateWarningBox(frame) -- se invocato direttamente in un template
end

return p
