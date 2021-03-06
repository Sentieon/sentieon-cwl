cwlVersion: v1.0
class: Workflow
doc: "DNAseq pipeline from fastq to vcf"
requirements:
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
    secondaryFiles:
      - .fai
      - .bwt
      - .sa
      - .ann
      - .amb
      - .pac
  input_reads:
    type:
      type: array
      items: [string, File]
  readgroup:
    type: string?
    default: group1
  sample:
    type: string?
    default: sample1
  library:
    type: string?
  platform:
    type: string?
    default: ILLUMINA
  mark_secondary:
    type: boolean?
  chunk_size:
    type: int?
  bam_compression:
    type: int?
  bwa_output_bam:
    type: string
    
  dedup_output_bam:
    type: string
  dedup_metrics_output_file:
    type: string
  dedup_traverse_param:
    type: string?

  bqsr_known_sites:
    type:
    - type: array
      items: [string, File] 
    secondaryFiles:
      - .tbi
  emit_mode:
    type: ["null", string]
    
  qcal_output_file:
    type: string

  dbsnp:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi
  output_file:
    type: string
  hc_interval:
    type: ["null", string, File]
  hc_traverse_param:
    type: string?
  threads:
    type: ["null", int]
    
outputs:
  bwa_output:
    type: File
    outputSource: bwa/output
  dedup_output:
    type: File
    outputSource: dedup/output
  dedup_metrics_output:
    type: ["null", File]
    outputSource: dedup/metrics_output
  qcal_output:
    type: File
    outputSource: bqsr/output
  output:
    type: File
    outputSource: hc/output    

steps:
  bwa:
    in:
      reference: reference
      reads: input_reads
      mark_secondary: mark_secondary
      chunk_size: chunk_size
      output_file: bwa_output_bam
      threads: threads
      bam_compression: bam_compression
      sort_threads: threads
      _readgroup: readgroup
      _sample: sample
      _platform: platform
      _library: library
      readgroup:
        valueFrom: |
          ${
            var rg = "@RG\tID:" + inputs._readgroup + "\tSM:" + inputs._sample
                     + "\tPL:" + inputs._platform;
            if ( inputs._library != null ) rg += "\tLB:" + inputs._library;
            return rg;
          }
    out: [output]      
    run: ../algo/bwa-mem-sort.cwl
  dedup:
    in:
      reference: reference
      input_bam: 
        source: bwa/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      metrics_output_file: dedup_metrics_output_file
      output_file: dedup_output_bam
      bam_compression: bam_compression
      traverse_param: dedup_traverse_param
      threads: threads
    out: [output, metrics_output]      
    run: ../stage/dedup-2-pass.cwl
  bqsr:
    in:
      reference: reference
      input_bam: 
        source: dedup/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      known_sites: bqsr_known_sites
      output_file: qcal_output_file
      threads: threads
    out: [output]
    run: ../algo/bqsr.cwl
  hc:
    in:
      reference: reference
      input_bam: 
        source: dedup/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      dbsnp: dbsnp
      output_file: output_file
      qcal: 
        source: bqsr/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      threads: threads
      traverse_param: hc_traverse_param
      interval: hc_interval
      advanced_options: {"default": ["--phmm_chunk_size", "1000"]}
      emit_mode: emit_mode
    out: [output]
    run: ../algo/hc.cwl


