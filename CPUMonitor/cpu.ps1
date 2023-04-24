Out-Null

$nc = (Get-CIMInstance -Class 'CIM_Processor').NumberOfCores
$nl = (Get-CIMInstance -Class 'CIM_Processor').NumberOfLogicalProcessors

write-host("name=Hardware Resources|CPU|NumberOfCores,aggregator=OBSERVATION,value=$nc")
write-host("name=Hardware Resources|CPU|NumberOfLogicalProcessors,aggregator=OBSERVATION,value=$nl")