cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, driver]
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: ["null", string, File]
    inputBinding:
      position: 10
      prefix: -r
    secondaryFiles:
      - .fai

  input_bam:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: -i
    inputBinding:
      position: 10
    secondaryFiles:
      - .bai

  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: -q
    inputBinding:
      position: 10
  
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
    default: "HsMetricAlgo"
    inputBinding:
      position: 100
      prefix: --algo
  
  targets_list:
    type: ["null", string, File]
    inputBinding:
      position: 110
      prefix: --targets_list

  baits_list:
    type: ["null", File]
    inputBinding:
      position: 110
      prefix: --baits_list

  clip_overlapping_reads:
    type: ["null", boolean]
    inputBinding:
      position: 110
      prefix: --clip_overlapping_reads

  min_map_qual:
    type: ["null", int]
    inputBinding:
      position: 110
      prefix: --min_map_qual

  min_base_qual:
    type: ["null", int]
    inputBinding:
      position: 110
      prefix: --min_base_qual

  coverage_cap:
    type: ["null", int]
    inputBinding:
      position: 110
      prefix: --coverage_cap
    
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
    type: File
    outputBinding:
      glob: $(inputs.output_file)
  log:
    type: stderr
stderr: hs-metrics.log


