function run_geospm_A(study_random_seed, varargin)
    
    if isempty(study_random_seed)
        study_random_seed = randi(2^31 - 1, 'int32');
    end
    
    options = hdng.utilities.parse_struct_from_varargin(varargin{:});
    options = geospm.validation.default_options(options);
    
    if ~isfield(options, 'generators')
        options.generators = {{'geospm.validation.generator_models.A:Koch Snowflake', 'Koch Snowflake'}};
    end
    
    options.experiments = geospm.validation.configure_experiments(options);
    options.generators = geospm.validation.configure_generators(options);
    
    options.controls = { {'a_probability', 'A Probability', 'dependency', 'noise_level', @noise_level_conversion}};
    
    randomisation_variables = {hdng.experiments.Schedule.REPETITION, 'noise_level'};
             
    optional_arguments = {};
    
    if isfield(options, 'sample_density')
        optional_arguments = [optional_arguments {'sample_density', options.sample_density }];
        randomisation_variables = [randomisation_variables {'sample_density'}];
    else 
        randomisation_variables = [randomisation_variables {'n_samples'}];
    end
    
    randomisation_variables = [randomisation_variables {'generator', 'domain_expression'}];
    
    options.randomisation_variables = randomisation_variables;
    
    arguments = hdng.utilities.struct_to_name_value_sequence(options);
    
    geospm.validation.run( ...
        'study_random_seed', study_random_seed, ...
        arguments{:}, ...
        optional_arguments{:});
end

function [value, description] = noise_level_conversion(value, ~)
    value = 1 - value;
    description = num2str(value);
end