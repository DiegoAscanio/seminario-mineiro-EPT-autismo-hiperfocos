-- abnt-fonte Pandoc filter

-- Compat: Lua 5.1 vs 5.2+
local unpack_ = table.unpack or unpack

-- Filtro 1: trata a classe .fonte
-- Transforma Divs com classe "fonte" em \begin{Fonte} ... \end{Fonte} no LaTeX.
-- Em outros formatos (docx/odt/html), mantém o conteúdo original.
local function FonteDiv(el)
  if not el.classes:includes("fonte") then
    return nil
  end

  if FORMAT:match("latex") then
    return {
      pandoc.RawBlock("latex", "\\begin{Fonte}"),
      unpack_(el.content),
      pandoc.RawBlock("latex", "\\end{Fonte}")
    }
  else
    -- Fora do LaTeX, não envolve em nada especial; apenas devolve o conteúdo.
    -- (Se quiser um fallback estilizado para docx/html, troque este return.)
    return el
  end
end

local filter_fonte = { Div = FonteDiv }

-- Retorne UMA LISTA de filtros (pode ter 1 ou mais)
return {
  filter_fonte,
  --- outros filtros aqui, se houver
}

