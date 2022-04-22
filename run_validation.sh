#!/bin/bash

indent=""
indent_step="   "

RUN_MODE=deferred
SCORE_MODE=always
REPLICATIONS="1 2 3 4 5 6 7 8 9 10"
NOISE_LEVELS="[0:1:35] / 100.0"
SMOOTHING_LEVELS="10:5:60"
SAMPLING_STRATEGY="'standard_sampling'"
COINCIDENT_OBSERVATIONS="'jitter'"
IS_REHEARSAL=false
RUN_UNIVARIATE=false
RUN_MULTIVARIATE=false

SNOWFLAKE_GENERATOR=false
ANTISNOWFLAKE_GENERATOR=false
SNOWFLAKE_FIELD_GENERATOR=false

SNOWFLAKES_SOLID_GENERATOR=false
SNOWFLAKES_NESTED_GENERATOR=false
ANTISNOWFLAKES_SOLID_GENERATOR=false

SNOWFLAKES_INTERACTION_GENERATOR=false

SNOWFLAKES_GENERATOR=false
ANTISNOWFLAKES_GENERATOR=false

KERNELS="gau=Gau"

EXPERIMENT_TYPES="spm=SPM krig=Kriging akde=AKDE"
RUN_PATH=

SCORES="geospm.validation.scores.Coverage \
        geospm.validation.scores.SelectSmoothingByCoverage \
        geospm.validation.scores.ConfusionMatrix \
        geospm.validation.scores.StructuralSimilarityIndex \
        geospm.validation.scores.AKDEBandwidth \
        geospm.validation.scores.ResidualSmoothness \
        geospm.validation.scores.ResidualVariances \
        geospm.validation.scores.VoxelCounts \
        geospm.validation.scores.InterclassCorrelation \
        geospm.validation.scores.HausdorffDistance \
        geospm.validation.scores.MahalanobisDistance"

WAIT_PERIOD=0
WAIT_INTERVAL=1
SKIP_INVOCATIONS=0
STOP_INVOCATIONS=0
UNIVARIATE_N_SAMPLES="600 1200 1800"
MULTIVARIATE_N_SAMPLES="1600 3200"
UNIVARIATE_ENCODINGS="=direct"
MULTIVARIATE_ENCODINGS="=direct_with_interactions"

EFFECT_SIZE="0.0"
REGIONALISATION="[]"

MATLAB_EXEC=/Applications/MATLAB_R2020a.app/bin/matlab
BASE_PATH="/Users/work/MATLAB"

if [ ! -f "${MATLAB_EXEC}" ]
then
    MATLAB_EXEC=/usr/local/MATLAB/R2020a/bin/matlab
    BASE_PATH="/data/holger/LOCALMATLAB"
fi

TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")

function where_am_i() {
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ]; do
      local dir="$( cd -P "$( dirname "$source" )" && pwd )"

      source="$(readlink "$source")"
      [[ $source != /* ]] && source="$dir/$source"
    done
    local dir="$( cd -P "$( dirname "$source" )" && pwd )"
    IFS= read -r "$1" <<<"$dir"
}

function print_arguments() {
    while [ "$1" != "" ]; do
      echo "Argument: $1"
      shift
    done
}

script_directory="$(pwd)"
where_am_i "script_directory"

EXPERIMENT_FUNCTION="run_experiments"

function usage() {
    local indent="   "
    echo "Usage: run_validation [...]"
    
    echo "${indent}Runs a geospm validation."
    
    echo "${indent}Options/Arguments:"
                    
    echo "${indent}{-m, --mode}          Run mode, one of {regular, deferred, resume}"
    echo "${indent}{--score-computation} Computation mode, one of {always, missing}"
    
    echo "${indent}{-r, --replications}  Replications formatted as a space separated list of numbers. Replications run in parallel. Optional."
    echo "${indent}{-n, --noise-levels}  Noise level(s) formatted as a Matlab numeric literal. Optional."
    echo "${indent}{-c, --scores}        Scores formatted as a space separated list of names. Optional."

    echo "${indent}{--univariate}        Include univariate experiments."
    echo "${indent}{--multivariate}      Include multivariate experiments."
    
    echo "${indent}{--univariate-samples}   Number of spatial samples as a space separated list of numbers (optional)"
    echo "${indent}{--multivariate-samples} Number of spatial samples as a space separated list of numbers (optional)"
        
                                
    echo "${indent}{--snowflake-generator} Include univariate snowflake generator."
    echo "${indent}{--antisnowflake-generator} Include univariate antisnowflake generator."
    echo "${indent}{--snowflake-field-generator} Include univariate snowflake field generator."
    
    echo "${indent}{--snowflakes-solid-generator} Include solid snowflakes generator."
    echo "${indent}{--snowflakes-nested-generator} Include nested snowflakes generator."
    echo "${indent}{--antisnowflakes-solid-generator} Include solid antisnowflakes generator."
    
    echo "${indent}{--snowflakes-interaction-generator} Include snowflakes interaction generator."
        
    echo "${indent}{--kernels}           A space separated list of prefixed kernel(s)"
    echo "${indent}{--smoothing-levels}  Smoothing levels as a space separated list of numbers"
            
    echo "${indent}{--effect-size}      Number of effect sizes as a space separated list of numbers (optional)"
            
    echo "${indent}{--sampling-strategy} Sampling strategy, one of {standard_sampling, standard_sampling2}"
    echo "${indent}{--coincident-observations} How to handle coincident observations, one of {identity, jitter, average, remove}"
    
    echo "${indent}{-t, --types}         Experiment types formatted as a space separated list of names in { SPM:spm, Kriging:krig }. Optional."
    
    echo "${indent}{-d, --rehearsal}     Flag for indicating this study is a rehearsal"
    
    echo "${indent}{--wait-period}       Wait period in seconds."
    echo "${indent}{--wait-interval}     Wait every n invocations."
    echo "${indent}{--skip}              Skip 0 or more invocations at the beginning."
    echo "${indent}{--stop}              Stop 0 or more invocations before the end."
    
    echo "${indent}directory"
}

while [ "$1" != "" ]; do
    
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -m | --mode )           shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --mode argument."; exit 1
                                fi
                                RUN_MODE=$1
                                ;;
        --score-computation )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --score-computation argument."; exit 1
                                fi
                                SCORE_MODE=$1
                                ;;
        -r | --replications )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --replications argument."; exit 1
                                fi
                                REPLICATIONS="$1"
                                ;;
        -n | --noise-levels )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --noise-levels argument."; exit 1
                                fi
                                NOISE_LEVELS="$1"
                                ;;
        -c | --scores )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --scores argument."; exit 1
                                fi
                                SCORES="$1"
                                ;;
        --univariate )          RUN_UNIVARIATE=true
                                ;;
        --multivariate )        RUN_MULTIVARIATE=true
                                ;;
        --snowflake-generator ) SNOWFLAKE_GENERATOR=true
                                ;;
        --antisnowflake-generator )
                                ANTISNOWFLAKE_GENERATOR=true
                                ;;
        --snowflake-field-generator )
                                SNOWFLAKE_FIELD_GENERATOR=true
                                ;;
        --snowflakes-solid-generator )
                                SNOWFLAKES_SOLID_GENERATOR=true
                                ;;
        --snowflakes-nested-generator )
                                SNOWFLAKES_NESTED_GENERATOR=true
                                ;;
        --antisnowflakes-solid-generator )
                                ANTISNOWFLAKES_SOLID_GENERATOR=true
                                ;;
        --snowflakes-interaction-generator )
                                SNOWFLAKES_INTERACTION_GENERATOR=true
                                ;;
        --snowflakes-generator )
                                SNOWFLAKES_GENERATOR=true
                                ;;
        --antisnowflakes-generator )
                                ANTISNOWFLAKES_GENERATOR=true
                                ;;
        --experiment-function ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --experiment-function argument."; exit 1
                                fi
                                EXPERIMENT_FUNCTION="$1"
                                ;;
        --univariate-samples )  shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --univariate-samples argument."; exit 1
                                fi
                                UNIVARIATE_N_SAMPLES="$1"
                                ;;
        --multivariate-samples ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --multivariate-samples argument."; exit 1
                                fi
                                MULTIVARIATE_N_SAMPLES="$1"
                                ;;
        --univariate-encodings )  shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --univariate-encodings argument."; exit 1
                                fi
                                UNIVARIATE_ENCODINGS="$1"
                                ;;
        --multivariate-encodings ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --multivariate-encodings argument."; exit 1
                                fi
                                MULTIVARIATE_ENCODINGS="$1"
                                ;;
        --effect-size )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --effect-size argument."; exit 1
                                fi
                                EFFECT_SIZE=$1
                                ;;
        --regionalisation )     shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --regionalisation argument."; exit 1
                                fi
                                REGIONALISATION=$1
                                ;;
        --kernels )             shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --kernels argument."; exit 1
                                fi
                                KERNELS=$1
                                ;;
        --smoothing-levels )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --smoothing-levels argument."; exit 1
                                fi
                                SMOOTHING_LEVELS="$1"
                                ;;
        --sampling-strategy )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --sampling-strategy argument."; exit 1
                                fi
                                SAMPLING_STRATEGY="$1"
                                ;;
        --coincident-observations ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --coincident-observations argument."; exit 1
                                fi
                                COINCIDENT_OBSERVATIONS="$1"
                                ;;
        -t | --types )          shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --types argument."; exit 1
                                fi
                                EXPERIMENT_TYPES="$1"
                                ;;
        -d | --rehearsal )      IS_REHEARSAL=true
                                ;;
        --wait-period )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --wait-period argument."; exit 1
                                fi
                                WAIT_PERIOD="$1"
                                ;;
        --wait-interval )       shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --wait-interval argument."; exit 1
                                fi
                                WAIT_INTERVAL="$1"
                                ;;
        --skip )                shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --skip argument."; exit 1
                                fi
                                SKIP_INVOCATIONS="$1"
                                ;;
        --stop )                shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --stop argument."; exit 1
                                fi
                                STOP_INVOCATIONS="$1"
                                ;;
        * )                     if [[ "$1" =~ -.* ]]; then
                                    echo "${indent}Unknown option: $1"; exit 1
                                fi
                                
                                if [ ${#RUN_PATH} -eq 0 ]; then
                                    RUN_PATH=$1
                                    shift
                                fi
                                
                                if [ "$#" -ne 0 ]; then
                                    echo "Unexpected arguments after directory argument: $@"; exit 1
                                fi
                                
                                break
                                ;;
    esac
    shift
done

run_experiments="${script_directory}/${EXPERIMENT_FUNCTION}.sh"

if [[ "$RUN_UNIVARIATE" == true ]]; then
    UNIVARIATE_ARGUMENT="--univariate"
else
    UNIVARIATE_ARGUMENT=
fi

if [[ "$RUN_MULTIVARIATE" == true ]]; then
    MULTIVARIATE_ARGUMENT="--multivariate"
else
    MULTIVARIATE_ARGUMENT=
fi

if [[ "$IS_REHEARSAL" == true ]]; then
    REHEARSAL_ARGUMENT="--rehearsal"
else
    REHEARSAL_ARGUMENT=
fi

if [[ "$RUN_MULTIVARIATE" == true && "$NO_INTERACTIONS" == true && "$NO_NONINTERACTIONS" == true ]]; then
    echo "Multivariate experiments are activated but both interacting and non-interacting generators are suppressed."; exit 1
fi

if [[ "$RUN_PATH" == "" ]]; then
    RUN_PATH="`pwd`/$TIMESTAMP"
fi

mkdir -p "$RUN_PATH"
RUN_PATH="$(cd $RUN_PATH; pwd)"

SNOWFLAKE="snowflake={'geospm.validation.generator_models.A:Koch Snowflake', 'Koch Snowflake'}"
ANTISNOWFLAKE="antisnowflake={'geospm.validation.generator_models.A:Koch Antisnowflake', 'Koch Antisnowflake'}"
SNOWFLAKE_FIELD="snowflake_field={'geospm.validation.generator_models.Aa:Koch Snowflake', 'Koch Snowflake Field'}"

SNOWFLAKES_SOLID="snowflakes_solid={'geospm.validation.generator_models.A_B_solid:Koch Snowflake', 'Koch Snowflakes, Solid'}"
SNOWFLAKES_NESTED="snowflakes_nested={'geospm.validation.generator_models.A_B_nested:Koch Snowflake', 'Koch Snowflakes, Nested'}"
ANTISNOWFLAKES_SOLID="antisnowflakes_solid={'geospm.validation.generator_models.A_B_solid:Koch Antisnowflake', 'Koch Antisnowflakes, Solid'}"

SNOWFLAKES_INTERACTION="snowflakes_axb={'geospm.validation.generator_models.A_AxB_B_3_regionalisation:Koch Snowflake', 'Koch Snowflakes'}"

SNOWFLAKES="snowflakes={'geospm.validation.generator_models.A_AxB_B:Koch Snowflake', 'Koch Snowflakes'}"
ANTISNOWFLAKES="antisnowflakes={'geospm.validation.generator_models.A_AxB_B:Koch Antisnowflake', 'Koch Antisnowflakes'}"


invocation="$run_experiments \
    $REHEARSAL_ARGUMENT \
    $UNIVARIATE_ARGUMENT \
    $MULTIVARIATE_ARGUMENT \
    --mode "\""$RUN_MODE"\"" \
    --score-computation "\""$SCORE_MODE"\"" \
    \
    --replications "\""$REPLICATIONS"\"" \
    --noise-levels "\""$NOISE_LEVELS"\"" \
    --types "\""$EXPERIMENT_TYPES"\"" \
    --scores "\""$SCORES"\"" \
    \
    --univariate-seed 0x25AFC7F6 \
    --multivariate-seed 0x51553A31 \
    \
    --univariate-encodings "\""$UNIVARIATE_ENCODINGS"\"" \
    --multivariate-encodings "\""$MULTIVARIATE_ENCODINGS"\"" \
    --univariate-samples "\""$UNIVARIATE_N_SAMPLES"\"" \
    --multivariate-samples "\""$MULTIVARIATE_N_SAMPLES"\"" \
    \
"

if [[ "$EXPERIMENT_FUNCTION" == "run_interactions" ]]; then
    invocation+=" \
--effect-size \"$EFFECT_SIZE\""
fi

if [[ "$EXPERIMENT_FUNCTION" == "run_interactions" ]]; then
    invocation+=" \
--regionalisation \"$REGIONALISATION\""
fi

if [[ "$SNOWFLAKE_GENERATOR" == true ]]; then
    invocation+=" \
--univariate-generator \"$SNOWFLAKE\""
fi

if [[ "$ANTISNOWFLAKE_GENERATOR" == true ]]; then
    invocation+=" \
--univariate-generator \"$ANTISNOWFLAKE\""
fi

if [[ "$SNOWFLAKE_FIELD_GENERATOR" == true ]]; then
    invocation+=" \
--univariate-generator \"$SNOWFLAKE_FIELD\""
fi

if [[ "$SNOWFLAKES_SOLID_GENERATOR" == true ]]; then
    invocation+=" \
--multivariate-generator \"$SNOWFLAKES_SOLID\""
fi

if [[ "$SNOWFLAKES_NESTED_GENERATOR" == true ]]; then
    invocation+=" \
--multivariate-generator \"$SNOWFLAKES_NESTED\""
fi

if [[ "$ANTISNOWFLAKES_SOLID_GENERATOR" == true ]]; then
    invocation+=" \
--multivariate-generator \"$ANTISNOWFLAKES_SOLID\""
fi

if [[ "$SNOWFLAKES_INTERACTION_GENERATOR" == true ]]; then
    invocation+=" \
--multivariate-generator \"$SNOWFLAKES_INTERACTION\""
fi

if [[ "$SNOWFLAKES_GENERATOR" == true ]]; then
    invocation+=" \
--multivariate-generator \"$SNOWFLAKES\""
fi

if [[ "$ANTISNOWFLAKES_GENERATOR" == true ]]; then
    invocation+=" \
--multivariate-generator \"$ANTISNOWFLAKES\""
fi

invocation+=" \
    --wait-period "\""$WAIT_PERIOD"\"" \
    --wait-interval "\""$WAIT_INTERVAL"\"" \
    --skip "\""$SKIP_INVOCATIONS"\"" \
    --stop "\""$STOP_INVOCATIONS"\"" \
    --kernels "\""$KERNELS"\"" \
    --smoothing-levels "\""$SMOOTHING_LEVELS"\"" \
    --smoothing-levels-p-value "\""0.95"\"" \
    --smoothing-method "\""default"\"" \
    --sampling-strategy "\""$SAMPLING_STRATEGY"\"" \
    --coincident-observations "\""$COINCIDENT_OBSERVATIONS"\"" \
    --noisy \
    "\""$RUN_PATH"\"" \
"

eval "$invocation"
