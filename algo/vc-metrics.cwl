cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, driver]
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
    inputBinding:
      position: 10
      prefix: -r
    secondaryFiles:
      - .fai

  interval:
    type: ["null", string, File]
    inputBinding:
      prefix: --interval
      position: 10

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10
    
  # algo starts with big position 100
  algo:
    type: string
    default: "CollectVCMetrics"
    inputBinding:
      position: 100
      prefix: --algo

  input_vcf:
    type: [string, File]
    inputBinding:
      position: 110
      prefix: --vcf
    secondaryFiles:
      - .tbi 

  dbsnp:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

  output_file:
    type: string
    inputBinding:
      position: 150

  advanced_options:
    type: 
    - "null"
    - type: array
      items: string
    inputBinding:
      position: 110    
  
outputs:
  output:
    type: File[]
    outputBinding:
      glob: $(inputs.output_file)*

  log:
    type: stderr
stderr: vc-metrics.log


