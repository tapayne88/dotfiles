return {
  'ckipp01/nvim-jenkinsfile-linter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('tap.utils').augroup('JenkinsfileLinter', {
      {
        events = { 'BufWritePost' },
        targets = { 'Jenkinsfile', 'Jenkinsfile.*' },
        command = function()
          if require('jenkinsfile_linter').check_creds() then
            require('jenkinsfile_linter').validate()
          end
        end,
      },
    })
  end,
}
