function run_geospm_A_AxB_B_3(study_random_seed, varargin)
    
    if isempty(study_random_seed)
        study_random_seed = randi(2^31 - 1, 'int32');
    end

    options = hdng.utilities.parse_struct_from_varargin(varargin{:});
    options = geospm.validation.default_options(options);
    
    options.generator_type = 'effects';
    options.noise_level = [];
    
    if ~isfield(options, 'generators')
        options.generators = {{'geospm.validation.generator_models.A_AxB_B_3_effect_size:Koch Snowflake', 'Koch Snowflakes'}};
    end
    
    options.experiments = geospm.validation.configure_experiments(options);
    options.generators = geospm.validation.configure_generators(options);
    
    if ~isfield(options, 'generator_parameterisation')
        if isfield(options, 'regionalisation')
            options.generator_parameterisation = 'regionalisation';
        elseif isfield(options, 'effect_size')
            options.generator_parameterisation = 'effect_size';
        else
            options.generator_parameterisation = 'separate';
        end
    end
    
    if ~isfield(options, 'effect_size')
        options.effect_size = num2cell(-1/7:12/35/10:1/5);
    end
    
    if ~isfield(options, 'null_probability')
        options.null_probability = { [0.25, 0.0, 0.0, 0.0] };
    end
    
    if ~isfield(options, 'effect_a')
        options.effect_a = { [0.0, 1.0, 0.0, 0.0] };
    end
    
    if ~isfield(options, 'effect_b')
        options.effect_b = { [0.0, 0.0, 1.0, 0.0] };
    end
    
    if ~isfield(options, 'interaction_effect_axb')
        options.interaction_effect_axb = { [0.0, 0.0, 0.0, 1.0] };
    end
    
    if ~isfield(options, 'regionalisation')
        options.regionalisation = { [0.25, 0.15, 0.15, 0.0;
                                     0.0,  0.2,  0.0,  0.15;
                                     0.0,  0.0,  0.2,  0.15;
                                     0.0,  0.0,  0.0,  0.4] };
    end
    
    if strcmp(options.generator_parameterisation, 'effect_size')
        options.controls = { {'effect_size', 'Effect Size', 'list', options.effect_size} ...
                           };
    elseif strcmp(options.generator_parameterisation, 'separate')
        
        options.controls = { {'null_probability', 'Null Probability', 'list', options.null_probability}, ...
                     {'effect_a', 'Effect A', 'list', options.effect_a}, ...
                     {'effect_b', 'Effect B', 'list', options.effect_b}, ...
                     {'interaction_effect_axb', 'Interaction Effect AxB', 'list', options.interaction_effect_axb}, ...
                   };
    elseif strcmp(options.generator_parameterisation, 'regionalisation')
        
        options.controls = { {'regionalisation', 'Regionalisation', 'list', options.regionalisation} ...
                   };
    end
    
    randomisation_variables = {hdng.experiments.Schedule.REPETITION};
    
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
