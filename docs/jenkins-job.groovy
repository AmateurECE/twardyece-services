multibranchPipelineJob('Documentation') {
  branchSources {
    git {
      id('docs-trunk')
      remote('https://github.com/AmateurECE/twardyece-repository.git')
      includes('trunk')
    }
  }
}
