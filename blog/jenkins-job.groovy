multibranchPipelineJob('Blog') {
  branchSources {
    git {
      id('blog-trunk')
      remote('https://github.com/AmateurECE/twardyece-blog.git')
      includes('trunk')
    }
  }
}
