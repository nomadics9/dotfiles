return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown' },
  build = function()
    vim.cmd 'packadd markdown-preview.nvim'
    vim.fn['mkdp#util#install']()
  end,
}
