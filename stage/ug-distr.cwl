cwlVersion: v1.0
class: Workflow
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs: 
  reference: 
    type: [string, File]
    secondaryFiles:
      - .fai
  input_bam:
    type:
    - type: array
      items: [string, File] 
    secondaryFiles:
      - .bai
  dbsnp:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi
  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]
  interval:
    type: ["null", string, File]
  output_file:
    type: string

  var_type:
    type: ["null", string]

  given:
    type: ["null", File]
    secondaryFiles:
      - .tbi

  annotation:
    type:
    - "null"
    - type: array
      items: string

  call_conf:
    type: ["null", double]

  emit_conf:
    type: ["null", double]

  emit_mode:
    type: ["null", string]

  min_base_qual:
    type: ["null", int]

  ploidy:
    type: ["null", int]

  shard:
    type: string[]

  advanced_options:
    type: 
    - "null"
    - type: array
      items: string

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10

outputs:
  output:
    type: File
    outputSource: merge/output

steps:
  ug:
    in:
      input_bam: input_bam
      qcal: qcal
      reference: reference
      threads: threads
      dbsnp: dbsnp
      var_type: var_type
      annotation: annotation
      call_conf: call_conf
      emit_conf: emit_conf
      emit_mode: emit_mode
      given: given
      min_base_qual: min_base_qual
      ploidy: ploidy
      interval: interval
      shard: shard
      _output: output_file # to provide base name for output_file
      _shard: shard # to deriver shard index
      output_file:
        source: shard
        linkMerge: merge_flattened
        valueFrom: |
          ${
            var len = inputs._shard.length;
            var i = 0;
            for (; i < len; ++i) {
               if (self == inputs._shard[i])
                 break;
            }
            return inputs._output + "_part_" + i + "." + inputs._output.split(".").pop();
          }
      advanced_options: advanced_options
    out: [output]
    scatter: [shard, output_file]
    scatterMethod: dotproduct
    run: ../algo/ug.cwl

  merge:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      part_output: ug/output
      output_file: output_file
    out: [output]
    run: ../algo/ug.cwl


