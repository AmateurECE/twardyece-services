multibranchPipelineJob('Repository') {
  branchSources {
    git {
      id('repository-trunk')
      remote('https://github.com/AmateurECE/twardyece-repository.git')
      includes('trunk')
    }
  }
}
