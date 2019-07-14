@{
  RootModule = 'pushd-nix.psm1'
  ModuleVersion = '0.1.0.0'
  GUID = '3b7bd751-268f-44e1-b748-0e3b3f69bf74'
  Author = 'Thelonius Kort'
  FunctionsToExport = @(
    'push-d'
    'pop-d'
    'dirs'
    'set-pushdAliases'
  )
  VariablesToExport = @(
  )
  AliasesToExport = @(
    'pushdn'
    'popdn'
  )
}

