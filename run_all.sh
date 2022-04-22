#!/bin/bash


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

run_validation="${script_directory}/run_validation.sh"

SCORES="geospm.validation.scores.ConfusionMatrix:always \
        geospm.validation.scores.StructuralSimilarityIndex \
        geospm.validation.scores.InterclassCorrelation \
        geospm.validation.scores.HausdorffDistance \
        geospm.validation.scores.MahalanobisDistance \
	    geospm.validation.scores.Coverage:always \
        geospm.validation.scores.SelectSmoothingByCoverage:always \
        "

NON_COVERAGE_SCORES="geospm.validation.scores.ConfusionMatrix:always \
        geospm.validation.scores.StructuralSimilarityIndex \
        geospm.validation.scores.InterclassCorrelation \
        geospm.validation.scores.HausdorffDistance \
        geospm.validation.scores.MahalanobisDistance \
        "

# "$run_validation" --mode regular --scores "$SCORES" --score-computation always --types "spm=SPM" --univariate --univariate-samples "600 1200 1800"  --snowflake-generator --antisnowflake-generator --snowflake-field-generator --wait-interval 1

# "$run_validation" --mode regular --scores "$SCORES" --score-computation always --types "krig=Kriging" --univariate --univariate-samples "600 1200 1800"  --snowflake-generator --antisnowflake-generator --snowflake-field-generator --wait-interval 1

# "$run_validation" --mode regular --scores "$SCORES" --score-computation always --types "spm=SPM" --multivariate --multivariate-samples "1600 3200" --multivariate-encodings "=direct" --snowflakes-generator --antisnowflakes-generator --wait-interval 1

# "$run_validation" --mode regular --scores "$SCORES" --score-computation always --types "krig=Kriging" --multivariate --multivariate-samples "1600 3200" --multivariate-encodings "=direct" --snowflakes-generator --antisnowflakes-generator --kernels "mat=Mat" --wait-interval 1

# "$run_validation" --mode regular --scores "$SCORES" --score-computation always --types "krig=Kriging" --multivariate --multivariate-samples "3200" --multivariate-encodings "=direct" --snowflakes-generator --kernels "gau=Gau" --wait-interval 1

# "$run_validation" --experiment-function "run_interactions" --noise-levels "[]" --mode deferred --scores "$SCORES" --score-computation always --types "spm=SPM" --multivariate-samples "15000" --multivariate-encodings "=direct_with_interactions" --snowflakes-interaction-generator --smoothing-levels "[30 45 60]" --regionalisation "[0.25,0.125,0.125,0.025;0.0,0.25,0.0,0.1000;0.0,0.0,0.25,0.1000;0.0,0.0,0.0,0.50] [0.25,0.125,0.125,0.025;0.0,0.25,0.0,0.1125;0.0,0.0,0.25,0.1125;0.0,0.0,0.0,0.45] [0.25,0.125,0.125,0.025;0.0,0.25,0.0,0.1250;0.0,0.0,0.25,0.1250;0.0,0.0,0.0,0.40] [0.25,0.125,0.125,0.025;0.0,0.25,0.0,0.1375;0.0,0.0,0.25,0.1375;0.0,0.0,0.0,0.35] [0.25,0.125,0.125,0.025;0.0,0.25,0.0,0.1500;0.0,0.0,0.25,0.1500;0.0,0.0,0.0,0.30] [0.25,0.125,0.125,0.025;0.0,0.25,0.0,0.1625;0.0,0.0,0.25,0.1625;0.0,0.0,0.0,0.25]" --wait-interval 1


echo "==== No more validations to run. ===="

