Function Show-AdSubGroup {
  param(
    [parameter(
      mandatory = $true,
      valueFromPipeline = $true
    )]
    [string]
      $group,
    
    [array]
      $parentGroup
  )
  begin {}
  process {
    try {
      $adgroup = get-adgroup $group -ea stop
      $parentGroup += $adgroup.samAccountName
    } catch {}
    if ($adgroup) {
      $subgroup = get-adgroup -ldapfilter "(memberof=$($adgroup.distinguishedname))"
      foreach ($sg in $subgroup) {
        if ($sg.samAccountName -in $parentGroup) {
          continue
        } else {
          ($parentgroup + $sg.samAccountName) -join " > "
          Show-AdSubGroup -group $sg.samAccountName -parentGroup $parentGroup
        }
      }
      $parentGroup = $null
    }
  }
  end {}
}

Function Show-AdParentGroup {
  param(
    [parameter(
      mandatory = $true,
      valueFromPipeline = $true
    )]
    [string]
      $member,
    
    [array]
      $parentGroup
  )
  begin {}
  process {
    try {
      $adgu = get-adgroup $member -ea stop
    } catch {
      try {
        $adgu = get-aduser $member -ea stop
      } catch {}
    }
    if ($adgu) {
      $parentGroup += $adgu.samAccountName
      $upgroup = get-adgroup -ldapfilter "(member=$($adgu.distinguishedname))"
      foreach ($ug in $upgroup) {
        if ($ug.samAccountName -in $parentGroup) {
          continue
        } else {
          ($parentgroup + $ug.samAccountName) -join " < "
          Show-AdParentGroup -member $ug.samAccountName -parentGroup $parentGroup
        }
      }
      $parentGroup = $null
    }
  }
  end {}
}

Function Show-AdCyclicGroup {
  param(
    [parameter(
      mandatory = $true,
      valueFromPipeline = $true
    )]
    [string]
      $group,
    
    [array]
      $parentGroup
  )
  begin {}
  process {
    try {
      $adgroup = get-adgroup $group -ea stop
      $parentGroup += $adgroup.samAccountName
    } catch {}
    if ($adgroup) {
      $subgroup = get-adgroup -ldapfilter "(memberof=$($adgroup.distinguishedname))"
      foreach ($sg in $subgroup) {
        if ($parentGroup -and $sg.samAccountName -eq $parentGroup[0]) {
          ($parentgroup + $sg.samAccountName) -join " > "
        } elseif ($sg.samAccountName -in $parentGroup) {
          continue
        } else {
          Show-AdCyclicGroup -group $sg.samAccountName -parentGroup $parentGroup
        }
      }
      $parentGroup = $null
    }
  }
  end {}
}

Function Test-AdCyclicGroup {
  param(
    [parameter(
      mandatory = $true,
      valueFromPipeline = $true
    )]
    [string]
      $groupDN
  )
  begin {}
  process {
    if ($groupDN -notmatch '^CN=') {
      $groupDN = (Get-ADGroup $groupDN).DistinguishedName 
    }
    $parentDN = (dsget group $groupDN -memberof -expand) -replace '"', ''
    if ($groupDN -in $parentDN) {
      $isCyclic = $true
    } else {
      $isCyclic = $false
    }
    return [pscustomobject]@{
      group = ($groupDN -replace 'CN=([^,]+),.*', '$1')
      isCyclic = $isCyclic
    }
  }
  end {}
}
