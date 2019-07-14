$pushd_stack = @()

function _tidy_pushd_stack(){
  if ($script:pushd_stack.count -lt 2){
    $script:pushd_stack = @($PWD)
  } else {
    $script:pushd_stack[0] = $PWD
  }
}

function _shift_pushd_stack($sign,[int]$amount){
  $sc = $script:pushd_stack.count
  if ($amount -ge $sc){
    Write-Host 'no such entry in dir stack'
    return $false
  }
  $amount = if ($sign -eq '+'){
      $amount + 1
    } else {
      $amount * -1
    }
  $script:pushd_stack = 0..($sc-1) | % { $script:pushd_stack[(($_-$amount) % $sc)] }
  return $true
}

function push-d(){
  param(
    [Parameter(Mandatory=$false)][string]$whereto
  )
  _tidy_pushd_stack
  if (-not $whereto){
    if ($script:pushd_stack.count -ge 2){
      $script:pushd_stack = (@($script:pushd_stack[1],$PWD,$script:pushd_stack[2..100] | ? {$_}) | % {$_})
    }
  } elseif (Test-Path $whereto -PathType Container){
    $wtnormed = $whereto -replace '\\$' | Resolve-Path
    $script:pushd_stack = @($wtnormed) + ($script:pushd_stack | ? { [string]$_ -ne [string]$wtnormed })
  } elseif ($whereto -match '^([-+])(\d+)$'){
    if (-not (_shift_pushd_stack $matches.1 $matches.2)){
      return
    }
  } else {
    Write-Host "No such container: '$dir'"
    return
  }
  Set-Location $script:pushd_stack[0]
  Write-Host ($script:pushd_stack -join ' ')
}

function pop-d(){
  param(
    [Parameter(Mandatory=$false)][string]$whereto
  )
  _tidy_pushd_stack
  if ($script:pushd_stack.count -lt 2){
    Write-Host 'directory stack empty'
    return
  } elseif (-not $whereto){
    $script:pushd_stack = $script:pushd_stack[1..100]
  } elseif ($whereto -match '^([-+])(\d+)$'){
    $ind = [int]$matches.2
    $sc = $script:pushd_stack.count
    if ($ind -ge $sc){
      Write-Host 'no such entry in dir stack'
      return
    }
    $item = if ($matches.1 -eq '+'){
        $sc - ($ind + 1)
      } else {
        $ind
      }
    # Write-Host ("should rid {0} because `$item is $item" -f $script:pushd_stack[$item])
    $script:pushd_stack = $script:pushd_stack | ? { $_ -ne $script:pushd_stack[$item] }
  }
  Set-Location $script:pushd_stack[0]
  Write-Host ($script:pushd_stack -join ' ')
}

function dirs(){
  param(
    [Parameter(Mandatory=$false)]$whereto
  )
  _tidy_pushd_stack
  Write-Host ($script:pushd_stack -join ' ')
}

Set-Alias pushdn push-d
Set-Alias popdn  pop-d

Export-ModuleMember -Function push-d, pop-d, dirs, set-pushdAliases
Export-ModuleMember -Alias pushdn, popdn
