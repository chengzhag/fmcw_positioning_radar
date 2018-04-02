classdef fallClassifierByFrame < matlab.System
    % fallClassifierByFrame
    % 以1*19作为输入的基于帧的跌到检测

    % Public, tunable properties
    properties
        
    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)
        CompactMdl % The compacted, trained model
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            % Load model from file
            obj.CompactMdl = loadCompactModel('../data/fall_classifier_by_frame_compactModel');
        end

        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            y = predict(obj.CompactMdl,u);
        end
        
        function flag = isInputSizeLockedImpl(obj,index)
            % Return true if input size is not allowed to change while
            % system is running
            flag = true;
        end
        
        function dataout = getOutputDataTypeImpl(~)
            dataout = 'double';
        end
        
        function sizeout = getOutputSizeImpl(~)
            sizeout = [1 1];
        end
        
        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end
    end
end
