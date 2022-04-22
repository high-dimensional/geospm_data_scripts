#!/bin/bash

indent=""
indent_step="  "

SUPPRESS_DIRECTORY_EXISTS=false

GEOSPM_RUN_PATH=
GEOSPM_FUNCTION_NAME=run_A_AxB_B
GEOSPM_STUDY_SEED=
GEOSPM_RUN_MODE=regular
GEOSPM_SCORE_MODE=always
GEOSPM_EVALUATION_PREFIX=
GEOSPM_EXPERIMENT_TYPES="{'SPM'}"
GEOSPM_DOMAIN_ENCODINGS="{'direct'}"
GEOSPM_N_SPATIAL_SAMPLES=1200
GEOSPM_NOISE_LEVELS="0.1"
GEOSPM_SCALE_FACTOR=1
GEOSPM_GENERATORS="{{'geospm.validation.generator_models.A_AxB_B:Koch Snowflake', 'Koch Snowflakes, No Interaction'}}"

GEOSPM_EFFECT_SIZE="0.0"
GEOSPM_REGIONALISATION="[]"
GEOSPM_SAMPLING_STRATEGY="'standard_sampling'"
GEOSPM_COINCIDENT_OBSERVATIONS_MODE="'jitter'"

GEOSPM_ADD_JITTER=false
GEOSPM_ADD_OBSERVATION_NOISE=false
GEOSPM_IS_REHEARSAL=false
GEOSPM_REPITITIONS=1

GEOSPM_SCORES=
GEOSPM_KERNELS=
GEOSPM_SMOOTHING_LEVELS=
GEOSPM_SMOOTHING_LEVELS_P_VALUE=
GEOSPM_SMOOTHING_METHOD=

GEOSPM_KRIGING_THRESHOLDS="{'normal [1, 2]: p < 0.05', 'normal [1]: p < 0.05', 'normal [2]: p < 0.05'}"
GEOSPM_SPM_THRESHOLDS="{'T[1,2]: p<0.05 (FWE)', 'T[1]: p<0.05 (FWE)', 'T[2]: p<0.05 (FWE)'}"
GEOSPM_AKDE_THRESHOLDS="{'normal [2]: p < 0.05', 'uniform [2]: p < 0.5'}"

GEOSPM_PROCESS_ID_FILE=


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

prepare_seed="${script_directory}/prepare_seed.sh"
collate_commands="${script_directory}/collate_commands.sh"

function usage() {
    local indent="   "
    echo "Usage: run_replications_in_parallel [...]"
    
    echo "${indent}Runs a multi-sample geospm experiment."
    
    echo "${indent}Options/Arguments:"
                
    echo "${indent}{-f, --function-name} Name of the Matlab function to be called"
    echo "${indent}{-s, --random-seed}   Random seed to be used for study (optional)"
    echo "${indent}{-m, --mode}          Run mode, one of {regular, deferred, resume}"
    echo "${indent}{--score-computation} Computation mode, one of {always, missing}"
    echo "${indent}{-p, --prefix}        Evaluation prefix. This is used for study and experiment directories."
    echo "${indent}{-t, --types}         Experiment types formatted as a Matlab cell array literal"
    echo "${indent}{-e, --encodings}     Domain encodings formatted as a Matlab cell array literal"
    echo "${indent}{-l, --n-locations}   Number of spatial samples as a space separated list of numbers"
    echo "${indent}{-n, --noise-levels}  Noise level(s) formatted as a Matlab numeric literal"
    echo "${indent}{-r, --replications}  Replications formatted as a space separated list of numbers. Replications run in parallel."
    echo "${indent}{-g, --generators}    Model generators formatted as a Matlab cell array literal"
    echo "${indent}{-c, --scores}        Scores formatted as a Matlab cell array literal"
    echo "${indent}{-j, --jitter}        Flag for adding jitter to spatial samples"
    echo "${indent}{-o, --noisy}         Flag for adding a small amount of uniform noise to observations"
    echo "${indent}{-d, --rehearsal}     Flag for indicating this study is a rehearsal"
    
    echo "${indent}{--kernels}           Kernel(s) formatted as a Matlab cell array literal"
    echo "${indent}{--smoothing-levels}  Smoothing levels as a space separated list of numbers"
    echo "${indent}{--smoothing-levels-p-value}  Smoothing levels p-value as a number"
    echo "${indent}{--smoothing-method}  Smoothing method"
    
    echo "${indent}{--kriging-thresholds}  Kriging Thresholds as a Matlab cell array literal"
    echo "${indent}{--spm-thresholds}    SPM Thresholds as a Matlab cell array literal"
    echo "${indent}{--akde-thresholds}   AKDE Thresholds as a Matlab cell array literal"
        
    echo "${indent}{--effect-size}       Effect size"
    
    echo "${indent}{--sampling-strategy} Sampling strategy, one of {standard_sampling, standard_sampling2}"
    echo "${indent}{--coincident-observations} Indicates how to handle coincident observations, one of {identity, jitter, average, remove}"
    
    echo "${indent}{--suppress-directory-exists} Suppresses a warning if the given directory already exist."
    
    echo "${indent}{--process-id-file}   Append process ids to file, one per line."
    
    echo "${indent}directory"
}

while [ "$1" != "" ]; do

    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -f | --function-name )  shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --function-name argument."; exit 1
                                fi
                                GEOSPM_FUNCTION_NAME="$1"
                                ;;
        -s | --random-seed )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --random-seed argument."; exit 1
                                fi
                                GEOSPM_STUDY_SEED="$1"
                                ;;
        -m | --mode )           shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --mode argument."; exit 1
                                fi
                                GEOSPM_RUN_MODE="$1"
                                ;;
        --score-computation )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --score-computation argument."; exit 1
                                fi
                                GEOSPM_SCORE_MODE="$1"
                                ;;
        -p | --prefix )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --prefix argument."; exit 1
                                fi
                                GEOSPM_EVALUATION_PREFIX="$1"
                                ;;
        -t | --types )          shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --types argument."; exit 1
                                fi
                                GEOSPM_EXPERIMENT_TYPES="$1"
                                ;;
        -e | --encodings )      shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --encodings argument."; exit 1
                                fi
                                GEOSPM_DOMAIN_ENCODINGS="$1"
                                ;;
        -l | --n-locations )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --n-locations argument."; exit 1
                                fi
                                GEOSPM_N_SPATIAL_SAMPLES="$1"
                                ;;
        -n | --noise-levels )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --noise-levels argument."; exit 1
                                fi
                                GEOSPM_NOISE_LEVELS="$1"
                                ;;
        -r | --replications )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --replications argument."; exit 1
                                fi
                                GEOSPM_REPITITIONS="$1"
                                ;;
        -g | --generators )     shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --generators argument."; exit 1
                                fi
                                GEOSPM_GENERATORS="$1"
                                ;;
        -c | --scores )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --scores argument."; exit 1
                                fi
                                GEOSPM_SCORES="$1"
                                ;;
        -j | --jitter )         GEOSPM_ADD_JITTER=true
                                ;;
        -o | --noisy )          GEOSPM_ADD_OBSERVATION_NOISE=true
                                ;;
        -d | --rehearsal )      GEOSPM_IS_REHEARSAL=true
                                ;;
        --kernels )             shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --kernels argument."; exit 1
                                fi
                                GEOSPM_KERNELS="$1"
                                ;;
        --smoothing-levels )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --smoothing-levels argument."; exit 1
                                fi
                                GEOSPM_SMOOTHING_LEVELS="$1"
                                ;;
        --smoothing-levels-p-value )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --smoothing-levels-p-value argument."; exit 1
                                fi
                                GEOSPM_SMOOTHING_LEVELS_P_VALUE="$1"
                                ;;
        --smoothing-method )    shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --smoothing-method argument."; exit 1
                                fi
                                GEOSPM_SMOOTHING_METHOD="$1"
                                ;;
        --kriging-thresholds )  shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --kriging-thresholds argument."; exit 1
                                fi
                                GEOSPM_KRIGING_THRESHOLDS="$1"
                                ;;
        --spm-thresholds )      shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --spm-thresholds argument."; exit 1
                                fi
                                GEOSPM_SPM_THRESHOLDS="$1"
                                ;;
        --akde-thresholds )     shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --akde-thresholds argument."; exit 1
                                fi
                                GEOSPM_AKDE_THRESHOLDS="$1"
                                ;;
        --sampling-strategy )   shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --sampling-strategy argument."; exit 1
                                fi
                                GEOSPM_SAMPLING_STRATEGY="$1"
                                ;;
        --effect-size )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --effect-size argument."; exit 1
                                fi
                                GEOSPM_EFFECT_SIZE="$1"
                                ;;
        --regionalisation )         shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --regionalisation argument."; exit 1
                                fi
                                GEOSPM_REGIONALISATION="$1"
                                ;;
        --coincident-observations ) shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --coincident-observations argument."; exit 1
                                fi
                                GEOSPM_COINCIDENT_OBSERVATIONS_MODE="$1"
                                ;;
        --suppress-directory-exists )  SUPPRESS_DIRECTORY_EXISTS=true
                                ;;
        --process-id-file)      shift
                                if [ "$#" -eq 0 ]; then
                                    echo "${indent}Missing --process-id-file argument."; exit 1
                                fi
                                GEOSPM_PROCESS_ID_FILE="$1"
                                ;;
        * )                     if [[ "$1" =~ -.* ]]; then
                                    echo "${indent}Unknown option: $1"; exit 1
                                fi
                                
                                if [ ${#GEOSPM_RUN_PATH} -eq 0 ]; then
                                    GEOSPM_RUN_PATH="$1"
                                    shift
                                fi
                                
                                if [ "$#" -ne 0 ]; then
                                    echo "Unexpected arguments after directory argument: $@"; exit 1
                                fi
                                
                                break
    esac
    shift
done

MATLAB_EXEC=/Applications/MATLAB_R2020a.app/bin/matlab
BASE_PATH="/Users/work/MATLAB"

if [ ! -f "${MATLAB_EXEC}" ]
then
    MATLAB_EXEC=/usr/local/MATLAB/R2020a/bin/matlab
    BASE_PATH="/data/holger/LOCALMATLAB"
fi

TIMESTAMP=$(date +"%Y_%m_%d_%H_%M_%S")

GEOSPM_FUNCTION_NAME="$(sed -e 's/^[[:space:]]*([^[:space:]]+)[[:space:]]*$//' <<< $GEOSPM_FUNCTION_NAME)"

if [ "$GEOSPM_FUNCTION_NAME" == "" ]; then
    echo "${indent}A Matlab function name must be specified as --function-name."; exit 1
fi

GEOSPM_STUDY_SEED=$($prepare_seed $GEOSPM_STUDY_SEED "Random seed") || exit 1
    
echo "${indent}[random-seed]"
echo "${indent}${indent_step}$GEOSPM_STUDY_SEED"
echo ""

if [ "$GEOSPM_EVALUATION_PREFIX" == "" ]; then
    echo "${indent}Note: No evaluation prefix was specified."
fi

if [ "$GEOSPM_RUN_PATH" != "" ]; then
    if [ ! -d "$GEOSPM_RUN_PATH" ]; then
        echo "${indent}The specified directory does not exist: $GEOSPM_RUN_PATH"; exit 1
    fi
else
    GEOSPM_RUN_PATH="$BASE_PATH/$TIMESTAMP"
fi

if [ "$GEOSPM_EVALUATION_PREFIX" != "" ]; then
    GEOSPM_RUN_PATH="${GEOSPM_RUN_PATH}/${GEOSPM_EVALUATION_PREFIX}"
fi

if [ "$GEOSPM_EVALUATION_PREFIX" != "" ]; then
    GEOSPM_EVALUATION_PREFIX="${GEOSPM_EVALUATION_PREFIX}_"
fi

if [ ! -d "$GEOSPM_RUN_PATH" ]; then
    printf "%s" "${indent}Creating session directory: \"$GEOSPM_RUN_PATH\"..."
    mkdir -p "$GEOSPM_RUN_PATH"
    echo "  Done."
elif [ "$SUPPRESS_DIRECTORY_EXISTS" != true ]; then
    echo "${indent}Session directory already exists: \"$GEOSPM_RUN_PATH\"."
    echo "${indent}Do you want to continue?"
    
    select reply in Yes No; do

        if [ "$reply" == "No" ]; then
            exit 0
        fi

        break
    done
fi

echo "${indent}Session files will be placed in \"${GEOSPM_RUN_PATH}\""

for I in ${GEOSPM_REPITITIONS}
do
    INSTANCE_DIRECTORY="${GEOSPM_RUN_PATH}/${I}"
    
    mkdir -p "$INSTANCE_DIRECTORY"
    
    INSTANCE_DIRECTORY="$(cd $INSTANCE_DIRECTORY; pwd)"
    
    OUTPUT_FILE="${INSTANCE_DIRECTORY}/${GEOSPM_EVALUATION_PREFIX}output_${I}.log"
    
    
    
    arguments="$GEOSPM_STUDY_SEED, ...
  'study_directory', '${INSTANCE_DIRECTORY}', ...
  'canonical_base_path', '${GEOSPM_RUN_PATH}', ...
  'domain_encoding', $GEOSPM_DOMAIN_ENCODINGS, ...
  'run_mode', '$GEOSPM_RUN_MODE', ...
  'default_score_mode', '$GEOSPM_SCORE_MODE', ...
  'repetition', {$I}, ...
  'n_samples', num2cell($GEOSPM_N_SPATIAL_SAMPLES), ...
  'noise_level', num2cell($GEOSPM_NOISE_LEVELS), ...
  'scale_factor', $GEOSPM_SCALE_FACTOR, ...
  'experiments', $GEOSPM_EXPERIMENT_TYPES, ...
  'generators', $GEOSPM_GENERATORS, ...
  'evaluation_prefix', '${GEOSPM_EVALUATION_PREFIX}', ...
  'sampling_strategy', $GEOSPM_SAMPLING_STRATEGY, ...
  'add_position_jitter', $GEOSPM_ADD_JITTER, ...
  'add_observation_noise', $GEOSPM_ADD_OBSERVATION_NOISE, ...
  'coincident_observations_mode', $GEOSPM_COINCIDENT_OBSERVATIONS_MODE, ...
  'is_rehearsal', $GEOSPM_IS_REHEARSAL"
        
    if [ "$GEOSPM_EFFECT_SIZE" != "" ]; then
        arguments+=", ...
  'effect_size', $GEOSPM_EFFECT_SIZE"
    fi
        
    if [ "$GEOSPM_REGIONALISATION" != "" ]; then
        arguments+=", ...
  'regionalisation', $GEOSPM_REGIONALISATION"
    fi
    
    if [ "$GEOSPM_KERNELS" != "" ]; then
        arguments+=", ...
  'kriging_kernel', "
        arguments+=$GEOSPM_KERNELS
    fi
    
    if [ "$GEOSPM_SMOOTHING_LEVELS" != "" ]; then
        arguments+=", ...
  'smoothing_levels', [$GEOSPM_SMOOTHING_LEVELS]"
    fi
    
    if [ "$GEOSPM_SMOOTHING_LEVELS_P_VALUE" != "" ]; then
        arguments+=", ...
  'smoothing_levels_p_value', $GEOSPM_SMOOTHING_LEVELS_P_VALUE"
    fi
    
    if [ "$GEOSPM_SMOOTHING_METHOD" != "" ]; then
        arguments+=", ...
  'smoothing_method', $GEOSPM_SMOOTHING_METHOD"
    fi
    
    if [ "$GEOSPM_SCORES" != "" ]; then
        arguments+=", ...
  'scores', $GEOSPM_SCORES"
    fi
    
    if [ "$GEOSPM_KRIGING_THRESHOLDS" != "" ]; then
        arguments+=", ...
  'kriging_thresholds', $GEOSPM_KRIGING_THRESHOLDS"
    fi
    
    if [ "$GEOSPM_SPM_THRESHOLDS" != "" ]; then
        arguments+=", ...
  'spm_thresholds', $GEOSPM_SPM_THRESHOLDS"
    fi
    
    if [ "$GEOSPM_AKDE_THRESHOLDS" != "" ]; then
        arguments+=", ...
  'akde_thresholds', $GEOSPM_AKDE_THRESHOLDS"
    fi
    
    function_call="$GEOSPM_FUNCTION_NAME(...
  $arguments);"
    
    echo "$function_call"
    #(echo "$function_call" | $MATLAB_EXEC -nodesktop -nodisplay -nosplash > "${OUTPUT_FILE}" | $collate_commands "$INSTANCE_DIRECTORY" ) &
    (echo "$function_call" | $MATLAB_EXEC -nodesktop -nodisplay -nosplash > "${OUTPUT_FILE}") &
    
    if [ "$GEOSPM_PROCESS_ID_FILE" != "" ]; then
        echo "$!:${INSTANCE_DIRECTORY}" >> "$GEOSPM_PROCESS_ID_FILE"
    fi
    
    sleep 1
done
