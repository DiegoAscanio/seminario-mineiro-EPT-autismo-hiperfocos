-- caption_top_universal.lua — Move a legenda da figura para o topo.
-- Funciona com Pandoc 2.x e 3.x, com e sem legendas.


-- caption_top_final.lua — Move a legenda para o topo e GERA MANUALMENTE O CÓDIGO DA IMAGEM.
-- Funciona com Pandoc 2.x e 3.x, com e sem legendas, e preserva a proporção da imagem.

-- Função auxiliar para construir a string de textwidth  LaTeX a partir do atributo width
-- se este existir
local function build_width(width)
  local opts = {}
  -- Converte "70%" para "0.7\textwidth"
  if string.match(width, '%%$') then
    local width_number = string.gsub(width, '%%', '')
    local num = tonumber(width_number) / 100
    table.insert(opts, 'width' .. '=' .. num .. '\\textwidth')
  else
    -- Para outras unidades (ex: "10cm"), apenas repassa
    table.insert(opts, 'width' .. '=' .. width)
  end
  return table.concat(opts, ',')
end

function FigurePlaceCaptionOnTop(fig)
  if FORMAT:match 'latex' then
    local caption = ''
    local image_cmd = ''
    local label = ''
    local centering = '  \\centering'
    local placement = '!ht' -- padrão

    -- (Parte da legenda, já está correta e robusta)
    if fig.caption then
      local caption_blocks = fig.caption.long
      if caption_blocks and #caption_blocks > 0 then
        caption = pandoc.write(pandoc.Pandoc(caption_blocks), 'latex')
      end
    end

    -- Encontra o elemento da imagem
    local image_element = nil
    pandoc.walk_block(fig, {
      Image = function(img)
        if not image_element then image_element = img end
      end
    })

    if image_element then
      -- --- MUDANÇA PRINCIPAL AQUI ---
      -- Em vez de usar pandoc.write, construímos o comando \includegraphics manualmente.
      local path = image_element.src
      local opts_str = nil

      -- processando o atributo width, se existir
      if image_element.attr.attributes['width'] then
        local width = image_element.attr.attributes['width']
        opts_str = build_width(width)
      end

      -- Define o posicionamento da figura, se existir
      if image_element.attr.attributes['placement'] then
        placement = image_element.attr.attributes['placement']
      end

      -- fazer para mais atributos posteriormente
      if opts_str ~= '' then
        image_cmd = '\\includegraphics[' .. opts_str .. ']{' .. path .. '}'
      else
        image_cmd = '\\includegraphics{' .. path .. '}'
      end

    else
      return nil
    end

    -- (Parte do label, já está correta)
    if fig.attr.identifier and fig.attr.identifier ~= "" then
      label = '  \\label{' .. fig.attr.identifier .. '}'
    end

    
    -- Monta a string final
    if caption ~= '' then
      caption = '\\caption{' .. caption .. '}'
    end

    local latex_output = table.concat({
      '\\begin{figure}[' .. placement .. ']',
      centering,
      '  ' .. caption,
      '  ' .. image_cmd,
      label,
      '\\end{figure}'
    }, '\n')

    return pandoc.RawBlock('latex', latex_output)
  end
  return nil
end

return {
  { Figure = FigurePlaceCaptionOnTop }
}
