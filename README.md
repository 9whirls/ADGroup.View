# ADGroup.View
Powershell module for a more user friendly view of AD group membership

Examples
==============
```
"Group A" | Show-ADSubGroup
Group A > Group B
Group A > Group B > Group C
Group A > Group B > Group D
Group A > Group E
Group A > Group E > Group C

"Group C" | Show-ADParentGroup
Group C < Group B
Group C < Group B < Group A
Group C < Group E
Group C < Group E < Group A

"User D" | Show-ADParentGroup
User D < Group D
User D < Group D < Group B
User D < Group D < Group B < Group A

"Group X" | Show-ADCyclicGroup
Group X > Group Y > Group Z > Group X

"Group A" | Test-ADCyclicGroup
group              isCyclic
-----              --------
Group A.              False
