@"
enable
config t
hostname Core_Bogota
!
interface FastEthernet0/0
 ip address 10.255.0.1 255.255.255.252
 no shutdown
!
interface Serial1/0.100 point-to-point
 ip address 10.255.1.1 255.255.255.252
 frame-relay interface-dlci 100
!
interface Serial1/0.101 point-to-point
 ip address 10.255.10.1 255.255.255.252
 frame-relay interface-dlci 101
!
interface Serial2/0
 ip address 10.255.2.1 255.255.255.252
 no shutdown
!
interface Serial2/1
 ip address 10.255.3.1 255.255.255.252
 no shutdown
!
interface GigabitEthernet3/0
 ip address 10.255.4.1 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
line con 0
 password cisco
 login
line vty 0 4
 password cisco
 login
!
end
"@ | Set-Content -Path "$env:TEMP\i1_startup-config.cfg" -Encoding ASCII

docker cp "${env:TEMP}\i1_startup-config.cfg" gns3-proyecto-final:/data/projects/Proyecto-Final-Redes/project-files/dynamips/4d72dadb-82a7-4a31-9928-f7de4005fce4/configs/ | Out-Null
Write-Host "✅ Core_Bogota"