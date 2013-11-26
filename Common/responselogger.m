classdef responselogger

% a class to handle participant's key responses and event log for your bahavior/fMRI/TMS experiments.
%
% [method]
% >> resps=resps.responselogger();
% >> resps=resps.set_keycodes(key_codes)                       : set key codes to be checked by the methods defined in this class.
% >> resps=resps.reset_keystatus()                             : reset all the key status.
% >> resps=resps.display_keycodes()                            : display key codes currently set in this class.
% >> resps=resps.unify_keys()                                  : unify key names across different operating systems
% >> [resps,oldkey]=resps.disable_jis_key_trouble()            : disable JIS key-related trouble (must run before the actual response acquisitions).
% >> [resps,event,keyCode]=resps.check_responses(event,reference_time) : check participant's key resonses and record them to the event log.
% >> [user_answer,resps]=resps.wait_to_proceed(:my_message)    : wait until the user responds to the question by 'y' (yes) or 'n' (no).
% >> [pstart,resps]=resps.wait_stimulus_presentation(:mode,:tgt_key) : wait for stimulus presentation.
% (: is optional)
%
% [about input/output variables]
% reference_time : reference time point to be used in logging the latter event time.
%                  e.g. reference_time=GetSecs();
% key_codes      : array of key codes, [1xn] matrix in which keycodes you want to check should be included.
%                  'q' and 'escape' are reserved to tell the program to force to quit.
% oldkey         : old key status before disabling default-ON JIS keys.
% event          : a MATLAB object generated by eventlogger.m
%                  event.event consists of MATLAB cell structure. each of cell has 3 elements below.
%                  {event_time(GetSecs()-reference_time),name_of_the_event,parameter_of_the_event}
% my_message     : message you want to display when waiting for participant's response to proceed the experiment.
% mode           : method to start the stimulus presentation
%                  0:ENTER/SPACE, 1:Left-mouse button, 2:the first MR trigger pulse (CiNet),
%                  3:waiting for a MR trigger pulse (BUIC) -- checking onset of pin #11 of the parallel port
%                  or 4:custom key trigger (wait for a key input that you specify as tgt_key).
%                  0 by default.
% start_key      : target key that you specify to detect a trigger to start a presentation. a character.
%                  the stimulus presentation will start when it gets tgt_key pressed.
%                  's' by default. But note that the tgt_key is used only when you set mode to 4.
% pstart         : 0 when some error happens, 1 when the presentation start correctly.
% user_answer    : 'true' or 'false'.
%
% [dependency]
% 1. Psychtoolbox ver.3 or above. Should be installed independently.
% 2. eventlogger.m
%
%
% Created    : "2013-11-17 21:42:47 ban"
% Last Update: "2013-11-23 00:45:43 ban (ban.hiroshi@gmail.com)"

properties (Hidden)  %(SetAccess = protected)
  key_codes=[37,39]; % array of key codes, [1xn] matrix in which keycodes you want to check should be included.
                     % 'q' and 'escape' are reserved to tell the program to force to quit.
  key_status=[0,0];  % array of key status, [1xn] matrix. generally all 0 by default. 1 when key is down.
  my_message='Are you ready to proceed? (y/n) : '; % message you want to display when waiting for participant's response to proceed the experiment.
  mode=0;
  start_key='s';
  quit_flg=0;
end

methods

  % constructor
  function obj=responselogger(key_codes)
    if nargin==1 && ~isempty(key_codes)
      obj.key_codes=key_codes;
      obj.key_status=zeros(1,numel(obj.key_codes));
    end
    %KbName('UnifyKeyNames');
  end

  % destructor
  function obj=delete(obj)
    % do nothing
  end

  % set key codes
  function obj=set_keycodes(obj,key_codes)
    if nargin<2 || isempty(key_codes), key_codes=[37,39]; end
    obj.key_codes=key_codes;
    obj.key_status=zeros(1,numel(obj.key_codes));
  end

  % rest key status
  function obj=reset_keystatus(obj)
    obj.key_status(:)=0;
  end

  % display key codes
  function obj=display_keycodes(obj)
    for ii=1:1:numel(obj.key_codes), fprintf('Key %02d: %d (%s)\n',ii,obj.key_codes(ii),KbName(obj.key_codes(ii))); end
  end

  % unify key names across different operating systems
  function obj=unify_keys(obj)
    KbName('UnifyKeyNames');
  end

  % disable JIS key-related trouble (must run before the actual response acquisitions)
  function [obj,oldkey]=disable_jis_key_trouble(obj)
    [keyIsDown,secs,keyCode]=KbCheck();
    oldkey=DisableKeysForKbCheck(find(keyCode>0));
  end

  % check participant's key responses and record them to the event log
  function [obj,event,keyCode]=check_responses(obj,event,specific_time)
    [keyIsDown,keysecs,keyCode]=KbCheck();
    if keyIsDown
      if (keyCode(KbName('q'))==1 || keyCode(KbName('escape'))==1) && ~obj.quit_flg % quit events - Q key or ESC
        Screen('CloseAll');
        if nargin==2
          event=event.add_event('Force quit',[]);
        elseif nargin==3
          event=event.add_event('Force quit',[],specific_time);
        end
        obj.quit_flg=1;
        finish;
      end

      for ii=1:1:numel(obj.key_codes)
        if keyCode(obj.key_codes(ii))==1 && obj.key_status(ii)==0 % check the target key press and the previous status
          if nargin==2
            event=event.add_event('Response',sprintf('key%d',ii));
          elseif nargin==3
            event=event.add_event('Response',sprintf('key%d',ii),specific_time);
          end
          obj.key_status(:)=0; obj.key_status(ii)=1;
        end
      end
    else
      obj.key_status(:)=0;
    end
  end

  % wait until the user responds to the question by 'y' (yes) or 'n' (no).
  function [user_answer,obj]=wait_to_proceed(obj,my_message)
    if nargin==2, obj.my_message=my_message; end
    while 1
      user_answer=input(obj.my_message,'s');
      if user_answer=='y'
        user_answer=true; break;
      elseif user_answer=='n'
        user_answer=false; break;
      else
        disp('Please press y or n!'); continue;
      end
    end
    obj.my_message='Are you ready to proceed? (y/n) : '; % put back to the default message.
    obj.key_status(:)=0;
    pause(0.5);
  end

  % wait for stimulus presentation.
  function [pstart,obj]=wait_stimulus_presentation(obj,mode,start_key)
    if nargin>=2 && ~isempty(mode), obj.mode=mode; end
    if nargin==3 && ~isempty(start_key), obj.start_key=start_key; end
    if isempty(intersect(obj.mode,0:1:3))
      error('mode should be 0:enter/space, 1:left-mouse button, or 2:waiting the first MR trigger. check input variable.');
    end

    pstart=0;
    if obj.mode==0 % in the lab or test, start with button press (SPACE or RETURN key)
      while pstart==0
        [keyIsDown,junk4,keyCode]=KbCheck();
        if keyCode(KbName('space')) || keyCode(KbName('return')), pstart=1; end
      end
    elseif obj.mode==1 % left-mouse button
      while pstart==0
        [x,y,mousebutton]=GetMouse();
        if mousebutton(1), pstart=1; end
      end
    elseif obj.mode==2 % MR trigger at CiNet
      while pstart==0
        [keyIsDown,junk4,keyCode]=KbCheck();
        if keyCode(KbName('t')) || keyCode(KbName('T')), pstart=1; end
      end
    elseif obj.mode==3 % waiting the first MR trigger from parallel port (BUIC)
      cleanpport(); %clear all parallel pins
      dio=digitalio('parallel','LPT1');  % set up parallel port
      addline(dio,1:16,'in');
      addline(dio,0,'out');
      pins=getvalue(dio);
      while pins(11)==0
        pins=getvalue(dio);
        if(pins(11)), pstart=1; break; end
      end
    elseif obj.mode==4 % custom key trigger
      while pstart==0
        [keyIsDown,junk4,keyCode]=KbCheck();
        if keyCode(KbName(obj.start_key)), pstart=1; end
      end
    end % if mode
  end

end % methods

end % classdef responselogger
