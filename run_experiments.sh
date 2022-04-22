#!/bin/bash

indent=""
indent_step="   "


MATLAB_EXEC=/Applications/MATLAB_R2020a.app/bin/matlab
BASE_PATH="/Users/work/MATLAB"

if [ ! -f "${MATLAB_EXEC}" ]
then
    MATLAB_EXEC=/usr/local/MATLAB/R2020a/bin/matlab
    BASE_PATH="/data/holger/LOCALMATLAB"
fi

TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")

RUN_PATH=
RUN_PATH_ARG=

RUN_MODE=regular
RUN_MODE_ARG=

SCORE_MODE=always
SCORE_MODE_ARG=

REPLICATIONS="1 2 3 4 5 6 8 9 10"
REPLICATIONS_ARG=

NOISE_LEVELS="[0:1:40] / 100.0"
NOISE_LEVELS_ARG=

EXPERIMENT_TYPES=(SPM, Kriging, AKDE)
EXPERIMENT_TYPE_PREFIXES=(spm, krig, akde)
EXPERIMENT_TYPES_ARG=

SCORES=(geospm.validation.scores.ConfusionMatrix \
        geospm.validation.scores.StructuralSimilarityIndex \
        geospm.validation.scores.AKDEBandwidth \
        geospm.validation.scores.ResidualSmoothness \
        geospm.validation.scores.ResidualVariances \
        geospm.validation.scores.VoxelCounts \
        geospm.validation.scores.InterclassCorrelation \
        geospm.validation.scores.HausdorffDistance \
        geospm.validation.scores.MahalanobisDistance \
        geospm.validation.scores.Coverage \
        geospm.validation.scores.SelectSmoothingByCoverage \
        )
SCORES_ARG=

RUN_UNIVARIATE=false
RUN_MULTIVARIATE=false
ADD_JITTER=false
ADD_OBSERVATION_NOISE=false
IS_REHEARSAL=false

UNIVARIATE_FUNCTION=run_geospm_A
MULTIVARIATE_FUNCTION=run_geospm_A_AxB_B

KERNELS=(Mat)
KERNEL_PREFIXES=(mat)
KERNELS_ARG=

SMOOTHING_LEVELS="5 10 25:25:250"
SMOOTHING_LEVELS_ARG=

SMOOTHING_LEVELS_P_VALUE="0.95"
SMOOTHING_LEVELS_P_VALUE_ARG=

SMOOTHING_METHOD="struct('type', 'default', 'diagnostics', true, 'parameters', struct('gaussian_method', 'matic2'))"
SMOOTHING_METHOD_ARG=


KRIGING_THRESHOLDS="{'normal [2]: p < 0.05'}"
KRIGING_THRESHOLDS_ARG=

SPM_THRESHOLDS="{'T[2]: p<0.05 (FWE)', 'T[1, 2]: p<0.05 (FWE)'}"
SPM_THRESHOLDS_ARG=

AKDE_THRESHOLDS="{'normal [2]: p < 0.05'}"
AKDE_THRESHOLDS_ARG=

SAMPLING_STRATEGY="'standard_sampling'"
SAMPLING_STRATEGY_ARG=

COINCIDENT_OBSERVATIONS="'jitter'"
COINCIDENT_OBSERVATIONS_ARG=

WAIT_PERIOD=0
WAIT_PERIOD_ARG=

WAIT_INTERVAL=1
WAIT_INTERVAL_ARG=

SKIP_INVOCATIONS=0
SKIP_INVOCATIONS_ARG=

STOP_INVOCATIONS=0
STOP_INVOCATIONS_ARG=

UNIVARIATE_SEED=
MULTIVARIATE_SEED=

UNIVARIATE_SEED=
UNIVARIATE_SEED_ARG=""
MULTIVARIATE_SEED=
MULTIVARIATE_SEED_ARG=""

UNIVARIATE_N_SAMPLES=(600 1200 1800)
UNIVARIATE_N_SAMPLES_ARG=

MULTIVARIATE_N_SAMPLES=(1600 3200)
MULTIVARIATE_N_SAMPLES_ARG=

UNIVARIATE_ENCODINGS=(direct)
UNIVARIATE_ENCODING_PREFIXES=(d)
UNIVARIATE_ENCODINGS_ARG=

MULTIVARIATE_ENCODINGS=(direct direct_with_interaction factorial_with_binary_levels)
MULTIVARIATE_ENCODING_PREFIXES=(d di f)
MULTIVARIATE_ENCODINGS_ARG=


UNIVARIATE_GENERATORS=(
  "{'geospm.validation.generator_models.A:Koch Snowflake', 'Koch Snowflake'}"
  "{'geospm.validation.generator_models.A:Koch Antisnowflake', 'Koch Antisnowflake'}"
  "{'geospm.validation.generator_models.Aa:Koch Snowflake', 'Koch Snowflake Field'}"
)

UNIVARIATE_GENERATORS_ARG=()

UNIVARIATE_GENERATOR_PREFIXES=(
  "snowflake"
  "antisnowflake"
  "snowflake_field"
)

MULTIVARIATE_GENERATORS=(
  "{'geospm.validation.generator_models.A_AxB_B:Koch Snowflake', 'Koch Snowflakes, No Interaction'}"
  "{'geospm.validation.generator_models.A_AxB_B_with_negative_interaction:Koch Snowflake', 'Koch Snowflakes, Negative Interaction'}"
  "{'geospm.validation.generator_models.A_AxB_B_with_positive_interaction:Koch Snowflake', 'Koch Snowflakes, Positive Interaction'}"
  
  "{'geospm.validation.generator_models.A_AxB_B:Koch Antisnowflake', 'Koch Antisnowflakes, No Interaction'}"
  "{'geospm.validation.generator_models.A_AxB_B_with_negative_interaction:Koch Antisnowflake', 'Koch Antisnowflakes, Negative Interaction'}"
  "{'geospm.validation.generator_models.A_AxB_B_with_positive_interaction:Koch Antisnowflake', 'Koch Antisnowflakes, Positive Interaction'}"
)

MULTIVARIATE_GENERATORS_ARG=()

MULTIVARIATE_GENERATOR_PREFIXES=(
  "noi_snowflakes"
  "ni_snowflakes"
  "pi_snowflakes"
  "noi_antisnowflakes"
  "ni_antisnowflakes"
  "pi_antisnowflakes"
)

PROCESS_LOG_FILE=

function print_array() {

    local ARRAY=
    eval "ARRAY=(\"\${$1[@]}\")"
    
    for i in "${!ARRAY[@]}"; do
        element="${ARRAY[i]}"
        echo "${indent}${indent_step}$element"
    done
    
    echo ""
}

function unique_array_from() {
    local ARRAY=($1)
    local ARRAY_NAME=$2
    local OUT_ARG=$3
    local IGNORE_ARG=$4
    
    if [ "$IGNORE_ARG" == "" ]; then
        IGNORE_ARG=true
    fi
    
    IFS=$'\n'
    local UNIQUE_ARRAY=($(echo "${ARRAY[*]}" | sort | uniq -))
    unset IFS
    
    if [ "$IGNORE_ARG" == false ]; then
        if [ ! "${#ARRAY[@]}" -eq "${#UNIQUE_ARRAY[@]}" ]; then
            echo "${indent}Error: $ARRAY_NAME contains duplicate elements."; exit -1
        fi
    fi
    
    IFS=$' '
    local TMP="${UNIQUE_ARRAY[*]}"
    unset IFS
    
    eval "$OUT_ARG=($TMP)"
}

function parse_specifier_from () {
    
    local SPECIFIER_ARG="$1"
    local ELEMENT_NAME="$2"
    local OUT_CONTENT="$3"
    local OUT_PREFIX="$4"
    local ALLOWABLE_CONTENT="$5"
    
    if [ "${#ALLOWABLE_CONTENT}" -eq 0 ]; then
        ALLOWABLE_CONTENT='[:alnum:]_.'
    fi
    
    PARTS=("$(cut -s -d '=' -f 1 <<< $SPECIFIER_ARG)" "$(cut -s -d '=' -f 2 <<< $SPECIFIER_ARG)")
            
    local SPECIFIER_PREFIX="${PARTS[0]}"
    local SPECIFIER_CONTENT="${PARTS[1]}"
            
    if [ "$SPECIFIER_CONTENT" == "" ]; then
        echo "${indent}Error: \"$SPECIFIER_CONTENT\" is not a valid $ELEMENT_NAME specifier content."; exit 1
    fi
    
    #if [ "$SPECIFIER_PREFIX" == "" ]; then
    #    echo "${indent}Error: \"$SPECIFIER_PREFIX\" is not a valid $ELEMENT_NAME specifier prefix."; exit 1
    #fi
    
    FILTERED_CONTENT="$(sed "s/[^$ALLOWABLE_CONTENT]//g" <<< ${SPECIFIER_CONTENT})"
    
    if [ "$SPECIFIER_CONTENT" != "$FILTERED_CONTENT" ]; then
        echo "$SPECIFIER_CONTENT"
        echo "$FILTERED_CONTENT"
        echo "${indent}Error: \"$SPECIFIER_CONTENT\" is not a valid $ELEMENT_NAME."; exit 1
    fi
    
    FILTERED_SPECIFIER_PREFIX="$(sed "s/[^$ALLOWABLE_CONTENT]//g" <<< ${SPECIFIER_PREFIX})"
    
    if [ "$SPECIFIER_PREFIX" != "$FILTERED_SPECIFIER_PREFIX" ]; then
        echo "${indent}Error: \"$SPECIFIER_PREFIX\" is not a valid $ELEMENT_NAME prefix."; exit 1
    fi
    
    eval "$OUT_CONTENT=\"$SPECIFIER_CONTENT\"; $OUT_PREFIX=\"$SPECIFIER_PREFIX\""
}

function parse_specifier_array_from() {

    local SPECIFIER_ARG="$1"
    local ARRAY_NAME="$2"
    local ELEMENT_NAME="$3"
    local OUT_ARG_1=$4
    local OUT_ARG_2=$5

    IFS=$' \t'
    local ENCODINGS_TMP=($SPECIFIER_ARG)
    unset IFS
            
    IFS=$' '
    unique_array_from "${ENCODINGS_TMP[*]}" "$ARRAY_NAME" ENCODINGS_TMP false
    unset IFS
    
    local ENCODINGS=()
    local ENCODING_PREFIXES=()
    
    for i in "${!ENCODINGS_TMP[@]}"; do
        local ENCODING_SPECIFIER="${ENCODINGS_TMP[i]}"
        
        local ENCODING=
        local ENCODING_PREFIX=
        
        parse_specifier_from "$ENCODING_SPECIFIER" "$ELEMENT_NAME" ENCODING ENCODING_PREFIX
        
        ENCODINGS+=("$ENCODING")
        ENCODING_PREFIXES+=("$ENCODING_PREFIX")
    done
    
    IFS=$' '
    local TMP_1="${ENCODINGS[@]}"
    unset IFS
    
    IFS=$' '
    local TMP_2="${ENCODING_PREFIXES[@]}"
    unset IFS
    
    eval "$OUT_ARG_1=($TMP_1); $OUT_ARG_2=($TMP_2)"
}

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

script_directory="$(pwd)"
where_am_i "script_directory"

run_replications="${script_directory}/run_replications_in_parallel.sh"
prepare_seed="${script_directory}/prepare_seed.sh"
barrier="${script_directory}/barrier.sh"

function usage() {
    local indent="   "
    echo "Usage: run_experiments [...]"
    
    echo "${indent}Runs a grid of multi-sample geospm experiments."
    
    echo "${indent}Options/Arguments:"
                    
    echo "${indent}{-m, --mode}          Run mode, one of {regular, deferred, resume}"
    echo "${indent}{--score-computation} Computation mode, one of {always, missing}"

    echo "${indent}{-r, --replications}  Replications formatted as a space separated list of numbers. Replications run in parallel. Optional."
    echo "${indent}{-n, --noise-levels}  Noise level(s) formatted as a Matlab numeric literal. Optional."
    echo "${indent}{-t, --types}         Experiment types formatted as a space separated list of names in { SPM:spm, Kriging:krig }. Optional."
    echo "${indent}{-c, --scores}        Scores formatted as a space separated list of names. Optional."
                
    echo "${indent}{--score-computation} Computation mode, one of {always, missing}"
    echo "${indent}{--univariate}        Include univariate experiments."
    echo "${indent}{--multivariate}      Include multivariate experiments."
    
    echo "${indent}{-j, --jitter}        Flag for adding jitter to spatial samples"
    echo "${indent}{-o, --noisy}         Flag for adding a small amount of uniform noise to observations"
    echo "${indent}{-d, --rehearsal}     Flag for indicating this study is a rehearsal"
    
    echo "${indent}{--wait-period}       Wait period in seconds."
    echo "${indent}{--wait-interval}     Wait every n invocations."
    echo "${indent}{--skip}              Skip 0 or more invocations at the beginning."
    echo "${indent}{--stop}              Stop 0 or more invocations before the end."
    
    echo "${indent}{--univariate-seed}   Univariate random seed to be used for study (optional)"
    echo "${indent}{--multivariate-seed} Multivariate random seed to be used for study (optional)"
                
    echo "${indent}{--univariate-encodings} Domain encodings formatted as a space separated list of names. Optional."
    echo "${indent}{--multivariate-encodings} Domain encodings formatted as a space separated list of names. Optional."
                
    echo "${indent}{--univariate-generator} Generator formatted as prefix=[MATLAB expr]. Can be used multiple times."
    echo "${indent}{--multivariate-generator} Generator formatted as prefix=[MATLAB expr]. Can be used multiple times."
            
    echo "${indent}{--univariate-samples}   Number of spatial samples as a space separated list of numbers (optional)"
    echo "${indent}{--multivariate-samples} Number of spatial samples as a space separated list of numbers (optional)"
    
    echo "${indent}{--kernels}           A space separated list of prefixed kernel(s)"
    echo "${indent}{--smoothing-levels}  Smoothing levels as a space separated list of numbers"
    echo "${indent}{--smoothing-levels-p-value}  Smoothing levels p-value as a number"
    echo "${indent}{--smoothing-method}  Smoothing method"
    
    echo "${indent}{--sampling-strategy} Sampling strategy, one of {standard_sampling, standard_sampling2}"
    echo "${indent}{--coincident-observations} How to handle coincident observations, one of {identity, jitter, average, remove}"
    
    
    echo "${indent}{--kriging-thresholds}  Kriging Thresholds as a Matlab cell array literal"
    echo "${indent}{--spm-thresholds}  SPM Thresholds as a Matlab cell array literal"
    echo "${indent}{--akde-thresholds} AKDE Thresholds as a Matlab cell array literal"
    echo "${indent}{--process-log-file} Path to the log file that will store the paths to completed processes."
        
    
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
                                RUN_MODE_ARG="$1"
                                ;;
        --score-computation )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --score-computation argument."; exit 1
                                fi
                                SCORE_MODE_ARG="$1"
                                ;;
        -r | --replications )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --replications argument."; exit 1
                                fi
                                REPLICATIONS_ARG="$1"
                                ;;
        -n | --noise-levels )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --noise-levels argument."; exit 1
                                fi
                                NOISE_LEVELS_ARG="$1"
                                ;;
        -t | --types )          shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --types argument."; exit 1
                                fi
                                EXPERIMENT_TYPES_ARG="$1"
                                ;;
        -c | --scores )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --scores argument."; exit 1
                                fi
                                SCORES_ARG="$1"
                                ;;
        --univariate )          RUN_UNIVARIATE=true
                                ;;
        --multivariate )        RUN_MULTIVARIATE=true
                                ;;
        -j | --jitter )         ADD_JITTER=true
                                ;;
        -o | --noisy )          ADD_OBSERVATION_NOISE=true
                                ;;
        -d | --rehearsal )      IS_REHEARSAL=true
                                ;;
        --wait-period )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --wait-period argument."; exit 1
                                fi
                                WAIT_PERIOD_ARG="$1"
                                ;;
        --wait-interval )       shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --wait-interval argument."; exit 1
                                fi
                                WAIT_INTERVAL_ARG="$1"
                                ;;
        --skip )                shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --skip argument."; exit 1
                                fi
                                SKIP_INVOCATIONS_ARG="$1"
                                ;;
        --stop )                shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --stop argument."; exit 1
                                fi
                                STOP_INVOCATIONS_ARG="$1"
                                ;;
        --univariate-seed )     shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --univariate-seed argument."; exit 1
                                fi
                                UNIVARIATE_SEED_ARG="$1"
                                ;;
        --multivariate-seed )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --multivariate-seed argument."; exit 1
                                fi
                                MULTIVARIATE_SEED_ARG="$1"
                                ;;
        --univariate-encodings ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --univariate-encodings argument."; exit 1
                                fi
                                UNIVARIATE_ENCODINGS_ARG="$1"
                                ;;
        --multivariate-encodings ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --multivariate-encodings argument."; exit 1
                                fi
                                MULTIVARIATE_ENCODINGS_ARG="$1"
                                ;;
        --univariate-generator ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --univariate-generator argument."; exit 1
                                fi
                                UNIVARIATE_GENERATORS_ARG+=("$1")
                                ;;
        --multivariate-generator ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --multivariate-generator argument."; exit 1
                                fi
                                MULTIVARIATE_GENERATORS_ARG+=("$1")
                                ;;
        --univariate-samples )  shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --univariate-samples argument."; exit 1
                                fi
                                UNIVARIATE_N_SAMPLES_ARG="$1"
                                ;;
        --multivariate-samples ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --multivariate-samples argument."; exit 1
                                fi
                                MULTIVARIATE_N_SAMPLES_ARG="$1"
                                ;;
        --kernels )             shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --kernels argument."; exit 1
                                fi
                                KERNELS_ARG=$1
                                ;;
        --smoothing-levels )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --smoothing-levels argument."; exit 1
                                fi
                                SMOOTHING_LEVELS_ARG="$1"
                                ;;
        --smoothing-levels-p-value )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --smoothing-levels-p-value argument."; exit 1
                                fi
                                SMOOTHING_LEVELS_P_VALUE_ARG="$1"
                                ;;
        --smoothing-method )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --smoothing-method argument."; exit 1
                                fi
                                SMOOTHING_METHOD_ARG="$1"
                                ;;
        --kriging-thresholds )  shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --kriging-thresholds."; exit 1
                                fi
                                KRIGING_THRESHOLDS_ARG="$1"
                                ;;
        --spm-thresholds )      shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --spm-thresholds."; exit 1
                                fi
                                SPM_THRESHOLDS_ARG="$1"
                                ;;
        --akde-thresholds )     shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --akde-thresholds."; exit 1
                                fi
                                AKDE_THRESHOLDS_ARG="$1"
                                ;;
        --sampling-strategy )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --sampling-strategy argument."; exit 1
                                fi
                                SAMPLING_STRATEGY_ARG="$1"
                                ;;
        --coincident-observations ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --coincident-observations argument."; exit 1
                                fi
                                COINCIDENT_OBSERVATIONS_ARG="$1"
                                ;;
        --process-log-file)     shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --process-log-file argument."; exit 1
                                fi
                                PROCESS_LOG_FILE="$1"
                                ;;
        * )                     if [[ "$1" =~ -.* ]]; then
                                    echo "${indent}Unknown option: $1"; exit 1
                                fi
                                
                                if [ ${#RUN_PATH_ARG} -eq 0 ]; then
                                    RUN_PATH_ARG="$1"
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

if [ "$RUN_MODE_ARG" != "" ]; then
    
    case $RUN_MODE_ARG in
        regular|deferred|resume|load) RUN_MODE=$RUN_MODE_ARG
                                 ;;
        *)                       echo "${indent}Error: Unknown run mode: $RUN_MODE_ARG"; exit 1
                                 ;;
    esac
    
    echo "${indent}[*run-mode]"
    echo "${indent}${indent_step}$RUN_MODE"
    echo ""
else
    echo "${indent}[run-mode]"
    echo "${indent}${indent_step}$RUN_MODE"
    echo ""
fi

if [ "$SCORE_MODE_ARG" != "" ]; then
    
    case $SCORE_MODE_ARG in
        always|missing)          SCORE_MODE=$SCORE_MODE_ARG
                                 ;;
        *)                       echo "${indent}Error: Unknown score computation: $SCORE_MODE_ARG"; exit 1
                                 ;;
    esac
    
    echo "${indent}[*score-computation]"
    echo "${indent}${indent_step}$SCORE_MODE"
    echo ""
else
    echo "${indent}[score-computation]"
    echo "${indent}${indent_step}$SCORE_MODE"
    echo ""
fi

if [ "$REPLICATIONS_ARG" != "" ]; then
    
    IFS=$' \t'
    REPLICATIONS_TMP=($REPLICATIONS_ARG)
    unset IFS
    
    for i in "${!REPLICATIONS_TMP[@]}"; do
        REPLICATION="${REPLICATIONS_TMP[i]}"
        FILTERED_REPLICATION="$(sed 's/[^[:digit:]]//g' <<< ${REPLICATION})"
                
        if [ "$REPLICATION" != "$FILTERED_REPLICATION" ]; then
            echo "${indent}Error: Expected --replications to be space-separated list of numbers but found: $REPLICATION"; exit 1
        fi
    done
        
    IFS=$' '
    unique_array_from "${REPLICATIONS_TMP[*]}" Replications REPLICATIONS_TMP false
    unset IFS
    
    IFS=$' '
    REPLICATIONS="${REPLICATIONS_TMP[*]}"
    unset IFS
    
    echo "${indent}[*replications]"
    echo "${indent}${indent_step}$REPLICATIONS"
    echo ""
else
    echo "${indent}[replications]"
    echo "${indent}${indent_step}$REPLICATIONS"
    echo ""
fi


if [ "$EXPERIMENT_TYPES_ARG" != "" ]; then
    
    parse_specifier_array_from "$EXPERIMENT_TYPES_ARG" "Experiment types" "experiment type" EXPERIMENT_TYPES EXPERIMENT_TYPE_PREFIXES
    
    echo "${indent}[*types] "
    print_array EXPERIMENT_TYPES
    
    echo "${indent}[*type-prefixes] "
    print_array EXPERIMENT_TYPE_PREFIXES
else
    echo "${indent}[types] "
    print_array EXPERIMENT_TYPES
    
    echo "${indent}[type-prefixes] "
    print_array EXPERIMENT_TYPE_PREFIXES
fi


if [ "$SCORES_ARG" != "" ]; then

    IFS=$' \t'
    SCORES_TMP=($SCORES_ARG)
    unset IFS
    
    SCORES=()
    
    for i in "${!SCORES_TMP[@]}"; do
        SCORE="${SCORES_TMP[i]}"
        FILTERED_SCORE="$(sed 's/[^[:alnum:]_.:]//g' <<< ${SCORE})"
        
        if [ "$SCORE" != "$FILTERED_SCORE" ]; then
            echo "${indent}Error: \"$SCORE\" is not a valid score."; exit 1
        fi
        
        SCORES+=("$FILTERED_SCORE")
    done
            
    IFS=$' '
    unique_array_from "${SCORES[*]}" Scores SCORES false
    unset IFS
    
    echo "${indent}[*scores] "
    print_array SCORES
else
    echo "${indent}[scores] "
    print_array SCORES
fi


if [ "$NOISE_LEVELS_ARG" != "" ]; then

    NOISE_LEVELS="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${NOISE_LEVELS_ARG})"
    
    if [ "$NOISE_LEVELS" == "" ]; then
        echo "${indent}Error: Invalid noise levels argument: $NOISE_LEVELS_ARG"; exit 1
    fi
    
    echo "${indent}[*noise-levels]"
    echo "${indent}${indent_step}$NOISE_LEVELS"
    echo ""
else
    echo "${indent}[noise-levels]"
    echo "${indent}${indent_step}$NOISE_LEVELS"
    echo ""
fi

if [ "$WAIT_PERIOD_ARG" != "" ]; then

    if [[ ! "$WAIT_PERIOD_ARG" =~ [0-9][0-9]* ]]; then
        echo "${indent}Error: Invalid wait period argument: $WAIT_PERIOD_ARG"; exit 1
    fi

    WAIT_PERIOD=$((WAIT_PERIOD_ARG))
        
    if [[ "$WAIT_INTERVAL" -lt 0 ]]; then
        echo "${indent}Error: Invalid wait period argument: $WAIT_INTERVAL"; exit 1
    fi
    
    echo "${indent}[*wait-period]"
    echo "${indent}${indent_step}$WAIT_PERIOD"
    echo ""
else
    echo "${indent}[wait-period]"
    echo "${indent}${indent_step}$WAIT_PERIOD"
    echo ""
fi

if [ "$WAIT_INTERVAL_ARG" != "" ]; then

    if [[ ! "$WAIT_INTERVAL_ARG" =~ [0-9][0-9]* ]]; then
        echo "${indent}Error: Invalid wait interval argument: $WAIT_INTERVAL_ARG"; exit 1
    fi

    WAIT_INTERVAL=$((WAIT_INTERVAL_ARG))
    
    if [[ "$WAIT_INTERVAL" -lt 1 ]]; then
        echo "${indent}Error: Invalid wait interval argument: $WAIT_INTERVAL"; exit 1
    fi
    
    echo "${indent}[*wait-interval]"
    echo "${indent}${indent_step}$WAIT_INTERVAL"
    echo ""
else
    echo "${indent}[wait-interval]"
    echo "${indent}${indent_step}$WAIT_INTERVAL"
    echo ""
fi

if [ "$SKIP_INVOCATIONS_ARG" != "" ]; then

    if [[ ! "$SKIP_INVOCATIONS_ARG" =~ [0-9][0-9]* ]]; then
        echo "${indent}Error: Invalid skip invocations argument: $SKIP_INVOCATIONS_ARG"; exit 1
    fi

    SKIP_INVOCATIONS=$((SKIP_INVOCATIONS_ARG))
    
    if [[ "$SKIP_INVOCATIONS" -lt 0 ]]; then
        echo "${indent}Error: Invalid skip invocations argument: $SKIP_INVOCATIONS"; exit 1
    fi
    
    echo "${indent}[*skip]"
    echo "${indent}${indent_step}$SKIP_INVOCATIONS"
    echo ""
else
    echo "${indent}[skip]"
    echo "${indent}${indent_step}$SKIP_INVOCATIONS"
    echo ""
fi

if [ "$STOP_INVOCATIONS_ARG" != "" ]; then

    if [[ ! "$STOP_INVOCATIONS_ARG" =~ [0-9][0-9]* ]]; then
        echo "${indent}Error: Invalid stop invocations argument: $STOP_INVOCATIONS_ARG"; exit 1
    fi

    STOP_INVOCATIONS=$((STOP_INVOCATIONS_ARG))
    
    if [[ "$STOP_INVOCATIONS" -lt 0 ]]; then
        echo "${indent}Error: Invalid stop invocations argument: $STOP_INVOCATIONS"; exit 1
    fi
    
    echo "${indent}[*stop]"
    echo "${indent}${indent_step}$STOP_INVOCATIONS"
    echo ""
else
    echo "${indent}[stop]"
    echo "${indent}${indent_step}$STOP_INVOCATIONS"
    echo ""
fi

UNIVARIATE_SEED=$($prepare_seed "$UNIVARIATE_SEED_ARG" "Univariate seed") || exit 1
    
echo "${indent}[univariate-seed]"
echo "${indent}${indent_step}$UNIVARIATE_SEED"
echo ""

MULTIVARIATE_SEED=$($prepare_seed "$MULTIVARIATE_SEED_ARG" "Multivariate seed") || exit 1
    
echo "${indent}[univariate-seed]"
echo "${indent}${indent_step}$MULTIVARIATE_SEED"
echo ""

if [ "$UNIVARIATE_N_SAMPLES_ARG" != "" ]; then

    IFS=$' \t'
    UNIVARIATE_N_SAMPLES_TMP=($UNIVARIATE_N_SAMPLES_ARG)
    unset IFS
    
    UNIVARIATE_N_SAMPLES=()
    
    for i in "${!UNIVARIATE_N_SAMPLES_TMP[@]}"; do
        SAMPLE="${UNIVARIATE_N_SAMPLES_TMP[i]}"
        FILTERED_SAMPLE="$(sed 's/[^[:digit:]]//g' <<< ${SAMPLE})"
        
        if [ "$SAMPLE" != "$FILTERED_SAMPLE" ]; then
            echo "${indent}Error: \"$SAMPLE\" is not a valid univariate sample number."; exit 1
        fi
        
        UNIVARIATE_N_SAMPLES+=("$FILTERED_SAMPLE")
    done
    
    IFS=$' '
    unique_array_from "${UNIVARIATE_N_SAMPLES[*]}" "Univariate sample numbers" UNIVARIATE_N_SAMPLES false
    unset IFS
    
    echo "${indent}[*univariate-samples] "
    print_array UNIVARIATE_N_SAMPLES
else
    echo "${indent}[univariate-samples] "
    print_array UNIVARIATE_N_SAMPLES
fi

if [ "$MULTIVARIATE_N_SAMPLES_ARG" != "" ]; then

    IFS=$' \t'
    MULTIVARIATE_N_SAMPLES_TMP=($MULTIVARIATE_N_SAMPLES_ARG)
    unset IFS
    
    MULTIVARIATE_N_SAMPLES=()
    
    for i in "${!MULTIVARIATE_N_SAMPLES_TMP[@]}"; do
        SAMPLE="${MULTIVARIATE_N_SAMPLES_TMP[i]}"
        FILTERED_SAMPLE="$(sed 's/[^[:digit:]]//g' <<< ${SAMPLE})"
        
        if [ "$SAMPLE" != "$FILTERED_SAMPLE" ]; then
            echo "${indent}Error: \"$SAMPLE\" is not a valid multivariate sample number."; exit 1
        fi
        
        MULTIVARIATE_N_SAMPLES+=("$FILTERED_SAMPLE")
    done
            
    IFS=$' '
    unique_array_from "${MULTIVARIATE_N_SAMPLES[*]}" "Multivariate sample numbers" MULTIVARIATE_N_SAMPLES false
    unset IFS
    
    echo "${indent}[*multivariate-samples] "
    print_array MULTIVARIATE_N_SAMPLES
else
    echo "${indent}[multivariate-samples] "
    print_array MULTIVARIATE_N_SAMPLES
fi


#GENERATOR_ALLOWABLE_PATTERN=$'[:alnum:][:space:]_:{}.,\\"\''
GENERATOR_ALLOWABLE_PATTERN="[:alnum:][:space:]_:{}.,'\"\\"


if [ "${#UNIVARIATE_GENERATORS_ARG[@]}" -ne 0 ]; then
    
    UNIVARIATE_GENERATORS=()
    UNIVARIATE_GENERATOR_PREFIXES=()
        
    for i in "${!UNIVARIATE_GENERATORS_ARG[@]}"; do
        SPECIFIER="${UNIVARIATE_GENERATORS_ARG[i]}"
        
        GENERATOR_PREFIX=
        GENERATOR=
        
        parse_specifier_from "$SPECIFIER" "univariate generator" GENERATOR GENERATOR_PREFIX "$GENERATOR_ALLOWABLE_PATTERN"
        
        UNIVARIATE_GENERATORS+=("$GENERATOR")
        UNIVARIATE_GENERATOR_PREFIXES+=("$GENERATOR_PREFIX")
    done
    
    #parse_specifier_array_from "$UNIVARIATE_GENERATORS_ARG" "Univariate generators" "generator" UNIVARIATE_GENERATORS UNIVARIATE_GENERATOR_PREFIXES
    
    echo "${indent}[*univariate-generators] "
    print_array UNIVARIATE_GENERATORS
    
    echo "${indent}[*univariate-generator-prefixes] "
    print_array UNIVARIATE_GENERATOR_PREFIXES
else
    echo "${indent}[univariate-generators] "
    print_array UNIVARIATE_GENERATORS
    
    echo "${indent}[univariate-generator-prefixes] "
    print_array UNIVARIATE_GENERATOR_PREFIXES
fi

if [ "${#MULTIVARIATE_GENERATORS_ARG[@]}" -ne 0 ]; then
            
    MULTIVARIATE_GENERATORS=()
    MULTIVARIATE_GENERATOR_PREFIXES=()
    
    for i in "${!MULTIVARIATE_GENERATORS_ARG[@]}"; do
        SPECIFIER="${MULTIVARIATE_GENERATORS_ARG[i]}"
        
        GENERATOR_PREFIX=
        GENERATOR=
                
        parse_specifier_from "$SPECIFIER" "multivariate generator" GENERATOR GENERATOR_PREFIX "$GENERATOR_ALLOWABLE_PATTERN"
        
        IFS=''
        MULTIVARIATE_GENERATORS+=("$GENERATOR")
        MULTIVARIATE_GENERATOR_PREFIXES+=("$GENERATOR_PREFIX")
        unset IFS
    done
    
    #parse_specifier_array_from "$MULTIVARIATE_GENERATORS_ARG" "Multivariate generators" "generator" MULTIVARIATE_GENERATORS MULTIVARIATE_GENERATOR_PREFIXES
            
    echo "${indent}[*multivariate-generators] "
    print_array MULTIVARIATE_GENERATORS
    
    echo "${indent}[*multivariate--generator-prefixes] "
    print_array MULTIVARIATE_GENERATOR_PREFIXES
else
    echo "${indent}[multivariate--generators] "
    print_array MULTIVARIATE_GENERATORS
    
    echo "${indent}[multivariate--generator-prefixes] "
    print_array MULTIVARIATE_GENERATOR_PREFIXES
fi

if [ "$UNIVARIATE_ENCODINGS_ARG" != "" ]; then
    
    parse_specifier_array_from "$UNIVARIATE_ENCODINGS_ARG" "Univariate encodings" "encoding" UNIVARIATE_ENCODINGS UNIVARIATE_ENCODING_PREFIXES
    
    echo "${indent}[*univariate-encodings] "
    print_array UNIVARIATE_ENCODINGS
    
    echo "${indent}[*univariate-encoding-prefixes] "
    print_array UNIVARIATE_ENCODING_PREFIXES
else
    echo "${indent}[univariate-encodings] "
    print_array UNIVARIATE_ENCODINGS
    
    echo "${indent}[univariate-encoding-prefixes] "
    print_array UNIVARIATE_ENCODING_PREFIXES
fi


if [ "$MULTIVARIATE_ENCODINGS_ARG" != "" ]; then
    
    parse_specifier_array_from "$MULTIVARIATE_ENCODINGS_ARG" "Multivariate encodings" "encoding" MULTIVARIATE_ENCODINGS MULTIVARIATE_ENCODING_PREFIXES
            
    echo "${indent}[*multivariate-encodings] "
    print_array MULTIVARIATE_ENCODINGS
    
    echo "${indent}[*multivariate-encoding-prefixes] "
    print_array MULTIVARIATE_ENCODING_PREFIXES
else
    echo "${indent}[multivariate-encodings] "
    print_array MULTIVARIATE_ENCODINGS
    
    echo "${indent}[multivariate-encoding-prefixes] "
    print_array MULTIVARIATE_ENCODING_PREFIXES
fi


if [ "$KERNELS_ARG" != "" ]; then
    
    parse_specifier_array_from "$KERNELS_ARG" "Kernels" "kernel" KERNELS KERNEL_PREFIXES
                
    echo "${indent}[*kernels] "
    print_array KERNELS
    
    echo "${indent}[*kernel-prefixes] "
    print_array KERNEL_PREFIXES
else
    echo "${indent}[kernels] "
    print_array KERNELS
    
    echo "${indent}[kernel-prefixes] "
    print_array KERNEL_PREFIXES
fi



if [ "$SMOOTHING_LEVELS_ARG" != "" ]; then

    SMOOTHING_LEVELS="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${SMOOTHING_LEVELS_ARG})"
    
    if [ "$SMOOTHING_LEVELS" == "" ]; then
        echo "${indent}Error: Invalid smoothing levels argument: $SMOOTHING_LEVELS_ARG"; exit 1
    fi
    
    echo "${indent}[*smoothing-levels]"
    echo "${indent}${indent_step}$SMOOTHING_LEVELS"
    echo ""
else
    
    echo "${indent}[smoothing-levels]"
    echo "${indent}${indent_step}$SMOOTHING_LEVELS"
    echo ""
fi


if [ "$SMOOTHING_LEVELS_P_VALUE_ARG" != "" ]; then
    
    SMOOTHING_LEVELS_P_VALUE="$(sed 's/[^[:digit:].]//g' <<< ${SMOOTHING_LEVELS_P_VALUE_ARG})"
    
    echo "${indent}[*smoothing-levels-p-value]"
    echo "${indent}${indent_step}$SMOOTHING_LEVELS_P_VALUE"
    echo ""
else
    echo "${indent}[smoothing-levels-p-value]"
    echo "${indent}${indent_step}$SMOOTHING_LEVELS_P_VALUE"
    echo ""
fi

if [ "$SMOOTHING_METHOD_ARG" != "" ]; then

    SMOOTHING_METHOD="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${SMOOTHING_METHOD_ARG})"
    
    if [ "$SMOOTHING_METHOD" == "" ]; then
        echo "${indent}Error: Invalid smoothing method argument: $SMOOTHING_METHOD_ARG"; exit 1
    fi
    
    echo "${indent}[*smoothing-method]"
    echo "${indent}${indent_step}$SMOOTHING_METHOD"
    echo ""
else
    
    echo "${indent}[smoothing-method]"
    echo "${indent}${indent_step}$SMOOTHING_METHOD"
    echo ""
fi


if [ "$KRIGING_THRESHOLDS_ARG" != "" ]; then

    KRIGING_THRESHOLDS="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${KRIGING_THRESHOLDS_ARG})"
    
    if [ "$KRIGING_THRESHOLDS" == "" ]; then
        echo "${indent}Error: Invalid kriging_thresholds argument: $KRIGING_THRESHOLDS_ARG"; exit 1
    fi
    
    echo "${indent}[*kriging-thresholds]"
    echo "${indent}${indent_step}$KRIGING_THRESHOLDS"
    echo ""
else
    
    echo "${indent}[kriging-thresholds]"
    echo "${indent}${indent_step}$KRIGING_THRESHOLDS"
    echo ""
fi


if [ "$SPM_THRESHOLDS_ARG" != "" ]; then

    SPM_THRESHOLDS="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${SPM_THRESHOLDS_ARG})"
    
    if [ "$SPM_THRESHOLDS" == "" ]; then
        echo "${indent}Error: Invalid spm_thresholds argument: $SPM_THRESHOLDS_ARG"; exit 1
    fi
    
    echo "${indent}[*spm-thresholds]"
    echo "${indent}${indent_step}$SPM_THRESHOLDS"
    echo ""
else
    
    echo "${indent}[spm-thresholds]"
    echo "${indent}${indent_step}$SPM_THRESHOLDS"
    echo ""
fi


if [ "$AKDE_THRESHOLDS_ARG" != "" ]; then

    AKDE_THRESHOLDS="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${AKDE_THRESHOLDS_ARG})"
    
    if [ "$AKDE_THRESHOLDS" == "" ]; then
        echo "${indent}Error: Invalid akde_thresholds argument: $AKDE_THRESHOLDS_ARG"; exit 1
    fi
    
    echo "${indent}[*akde-thresholds]"
    echo "${indent}${indent_step}$AKDE_THRESHOLDS"
    echo ""
else
    
    echo "${indent}[akde-thresholds]"
    echo "${indent}${indent_step}$AKDE_THRESHOLDS"
    echo ""
fi


if [ "$SAMPLING_STRATEGY_ARG" != "" ]; then

    SAMPLING_STRATEGY="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${SAMPLING_STRATEGY_ARG})"
    
    if [ "$SAMPLING_STRATEGY" == "" ]; then
        echo "${indent}Error: Invalid sampling-strategy argument: $SAMPLING_STRATEGY_ARG"; exit 1
    fi
    
    echo "${indent}[*sampling-strategy]"
    echo "${indent}${indent_step}$SAMPLING_STRATEGY"
    echo ""
else
    
    echo "${indent}[sampling-strategy]"
    echo "${indent}${indent_step}$SAMPLING_STRATEGY"
    echo ""
fi


if [ "$COINCIDENT_OBSERVATIONS_ARG" != "" ]; then

    COINCIDENT_OBSERVATIONS="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${COINCIDENT_OBSERVATIONS_ARG})"
    
    if [ "$COINCIDENT_OBSERVATIONS" == "" ]; then
        echo "${indent}Error: Invalid coincident-observations argument: $COINCIDENT_OBSERVATIONS_ARG"; exit 1
    fi
    
    echo "${indent}[*coincident-observations]"
    echo "${indent}${indent_step}$COINCIDENT_OBSERVATIONS"
    echo ""
else
    
    echo "${indent}[coincident-observations]"
    echo "${indent}${indent_step}$COINCIDENT_OBSERVATIONS"
    echo ""
fi

if [ "$RUN_PATH_ARG" != "" ]; then
    if [ ! -d "$RUN_PATH_ARG" ]; then
        echo "${indent}The specified directory does not exist: $RUN_PATH_ARG"; exit 1
    fi
    
    RUN_PATH="$RUN_PATH_ARG"
else
    RUN_PATH=
fi


if [ "$PROCESS_LOG_FILE" == "" ]; then
    PROCESS_LOG_FILE="$RUN_PATH/completed.log"
fi

PROCESS_ID_FILE="$RUN_PATH/running_pids.txt"

touch "$PROCESS_ID_FILE"
touch "$PROCESS_LOG_FILE"

SCORES_MATLAB=

for s in "${!SCORES[@]}"; do
    score="${SCORES[s]}"
    SCORES_MATLAB+="'$score' "
done

SCORES_MATLAB="{ $SCORES_MATLAB }"

function run_each_validation() {
    
    local FUNCTION=$1
    local SEED=$2
    
    local GENERATORS=
    local GENERATOR_PREFIXES=
    
    eval "GENERATORS=(\"\${$3[@]}\")"
    eval "GENERATOR_PREFIXES=(\"\${$4[@]}\")"
    
    local ENCODINGS=
    local ENCODING_PREFIXES=
    
    eval "ENCODINGS=(\"\${$5[@]}\")"
    eval "ENCODING_PREFIXES=(\"\${$6[@]}\")"
    
    local N_SAMPLES=
    
    eval "N_SAMPLES=(\"\${$7[@]}\")"
    
    local WAIT_PERIOD=$8
    local WAIT_INTERVAL=$9
    local SKIP_INVOCATIONS="${10}"
    local STOP_INVOCATIONS="${11}"
    
    if [ "${#KERNELS[@]}" -eq 0 ]; then
        KERNELS=("!")
        KERNEL_PREFIXES=("")
    fi
    
    local interval=0
    local interval_count=$(( ${#KERNELS[@]} * ${#N_SAMPLES[@]} * ${#ENCODINGS[@]} * ${#GENERATORS[@]} * ${#EXPERIMENT_TYPES[@]} ))
    
    local interval_limit=$(( $interval_count - $STOP_INVOCATIONS ))
    
    for k in "${!KERNELS[@]}"; do
    
        KERNEL="${KERNELS[k]}"
        KERNEL_PREFIX="${KERNEL_PREFIXES[k]}"
        
        if [ "$KERNEL_PREFIX" != "" ]; then
            KERNEL_PREFIX="${KERNEL_PREFIX}_"
        fi
    
        for j in "${!N_SAMPLES[@]}"; do
            
            SAMPLE_NUMBER="${N_SAMPLES[j]}"
            
            for c in "${!ENCODINGS[@]}"; do

                ENCODING="${ENCODINGS[c]}"
                ENCODING_PREFIX="${ENCODING_PREFIXES[c]}"
                
                if [ "$ENCODING_PREFIX" != "" ]; then
                    ENCODING_PREFIX="${ENCODING_PREFIX}_"
                fi
                
                for i in "${!GENERATORS[@]}"; do
                
                    GENERATOR="${GENERATORS[i]}"
                    GENERATOR_PREFIX="${GENERATOR_PREFIXES[i]}"
                    
                    if [ "$GENERATOR_PREFIX" != "" ]; then
                        GENERATOR_PREFIX="${GENERATOR_PREFIX}_"
                    fi
                        
                    for t in "${!EXPERIMENT_TYPES[@]}"; do
                    
                        if [[ $interval -lt $SKIP_INVOCATIONS ]]; then
                            interval=$((interval + 1))
                            continue
                        fi
                        
                        EXPERIMENT_TYPE="${EXPERIMENT_TYPES[t]}"
                        EXPERIMENT_TYPE_PREFIX="${EXPERIMENT_TYPE_PREFIXES[t]}"
                        
                        if [ "$EXPERIMENT_TYPE_PREFIX" != "" ]; then
                            EXPERIMENT_TYPE_PREFIX="${EXPERIMENT_TYPE_PREFIX}_"
                        fi
                        
                        SAVED_GENERATOR_PREFIX="$GENERATOR_PREFIX"
                        SAVED_ENCODING_PREFIX="$ENCODING_PREFIX"
                        SAVED_KERNEL_PREFIX="$KERNEL_PREFIX"
                        
                        #echo "Current Experiment: $EXPERIMENT_TYPE"
                        #echo "Current Generator: $GENERATOR"
                        #echo "Current Number of Samples: $SAMPLE_NUMBER"
                        #echo "Current Encoding: $ENCODING"
                        #echo "Current Kernel: $KERNEL"
                        
                        if [ "$EXPERIMENT_TYPE" == "SPM" ]; then
                            KERNEL_PREFIX=""
                        elif [ "$EXPERIMENT_TYPE" == "AKDE" ]; then
                            KERNEL_PREFIX=""
                        elif [ "$EXPERIMENT_TYPE" == "Kriging" ]; then
                            : Do nothing
                        fi
                        
                        invocation="$run_replications \
                            --suppress-directory-exists \
                            --function-name $FUNCTION \
                            --random-seed $SEED \
                            --mode $RUN_MODE \
                            --score-computation $SCORE_MODE \
                            --prefix \"${EXPERIMENT_TYPE_PREFIX}${KERNEL_PREFIX}${GENERATOR_PREFIX}${ENCODING_PREFIX}${SAMPLE_NUMBER}\" \
                            --types \"{'${EXPERIMENT_TYPE}'}\" \
                            --encodings \"{'$ENCODING'}\" \
                            --n-locations \"$SAMPLE_NUMBER\" \
                            --noise-levels \"$NOISE_LEVELS\" \
                            --replications \"$REPLICATIONS\" \
                            --generators \"{$GENERATOR}\" \
                            --scores \"$SCORES_MATLAB\" \
                            --sampling-strategy \"$SAMPLING_STRATEGY\" \
                            --coincident-observations \"$COINCIDENT_OBSERVATIONS\""
                        
                        if [ "$ADD_JITTER" == true ]; then
                            invocation+="\
                             --jitter"
                        fi

                        if [ "$ADD_OBSERVATION_NOISE" == true ]; then
                            invocation+="\
                             --noisy"
                        fi

                        if [ "$IS_REHEARSAL" == true ]; then
                            invocation+="\
                             --rehearsal"
                        fi
                        
                        if [ "$EXPERIMENT_TYPE" == "SPM" ]; then
                        
                           invocation+="\
                            --smoothing-levels \"$SMOOTHING_LEVELS\" \
                            --smoothing-levels-p-value \"$SMOOTHING_LEVELS_P_VALUE\" \
                            --smoothing-method \"'$SMOOTHING_METHOD'\" \
                            --spm-thresholds \"$SPM_THRESHOLDS\""
                        elif [ "$EXPERIMENT_TYPE" == "Kriging" ]; then
                            invocation+="\
                            --kernels \"{'$KERNEL'}\" \
                            --kriging-thresholds \"$KRIGING_THRESHOLDS\""
                        elif [ "$EXPERIMENT_TYPE" == "AKDE" ]; then
                            invocation+="\
                            --kernels \"{'$KERNEL'}\" \
                            --akde-thresholds \"$AKDE_THRESHOLDS\""
                        fi
                        
                        invocation+="\
                            --process-id-file \"$PROCESS_ID_FILE\" \
                            $RUN_PATH"
                        
                        GENERATOR_PREFIX="$SAVED_GENERATOR_PREFIX"
                        ENCODING_PREFIX="$SAVED_ENCODING_PREFIX"
                        KERNEL_PREFIX="$SAVED_KERNEL_PREFIX"
                        
                        eval "$invocation"
                        
                        interval=$((interval + 1))
                        
                        if [[ $interval -eq $interval_limit ]]; then
                            echo "Reached interval stop."
                            exit 0
                        fi
                        
                        if [[ $(($interval % $WAIT_INTERVAL)) -eq 0 ]]; then
                            TIMESTAMP=$(date +"%Y/%m/%d %H:%M:%S")
                            # echo "$TIMESTAMP: Sleeping for $WAIT_PERIOD seconds..."
                            # sleep $WAIT_PERIOD
                            echo "$TIMESTAMP: Reached barrier..."
                            "$barrier" -p "$PROCESS_ID_FILE" -l "$PROCESS_LOG_FILE" -w 60
                        fi
                    done
                done
            done
        done
    done
}


if [[ "$RUN_UNIVARIATE" == true ]]; then

    echo "${indent}Running univariate validations:"
    
    run_each_validation \
        $UNIVARIATE_FUNCTION \
        $UNIVARIATE_SEED \
        UNIVARIATE_GENERATORS \
        UNIVARIATE_GENERATOR_PREFIXES \
        UNIVARIATE_ENCODINGS \
        UNIVARIATE_ENCODING_PREFIXES \
        UNIVARIATE_N_SAMPLES \
        "$WAIT_PERIOD" \
        "$WAIT_INTERVAL" \
        "$SKIP_INVOCATIONS" \
        "$STOP_INVOCATIONS"
    
    
fi

if [[ "$RUN_MULTIVARIATE" == true ]]; then
    
    echo "${indent}Running multivariate validations:"
    
    run_each_validation \
        $MULTIVARIATE_FUNCTION \
        $MULTIVARIATE_SEED \
        MULTIVARIATE_GENERATORS \
        MULTIVARIATE_GENERATOR_PREFIXES \
        MULTIVARIATE_ENCODINGS \
        MULTIVARIATE_ENCODING_PREFIXES \
        MULTIVARIATE_N_SAMPLES \
        "$WAIT_PERIOD" \
        "$WAIT_INTERVAL" \
        "$SKIP_INVOCATIONS" \
        "$STOP_INVOCATIONS"
fi


exit 0


