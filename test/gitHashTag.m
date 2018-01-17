% 
% gitHashTag - latest hash tag from the current git repo
%

% some notes:
% [PATHSTR,NAME,EXT] = fileparts(p)
% git -c pager.log=false
% git --no-pager
% git log --pretty=format:"%h"
% git --no-pager log -1 --pretty=format:"%h"

function htag = gitHashTag

% command for the hashtag
repo = fileparts(mfilename('fullpath'));
gcmd = 'git --no-pager log -1 --pretty=format:"%h"';
ucmd = sprintf('cd %s; %s', repo, gcmd');

% try to execute the command
[s, w] = unix(ucmd);

% return hashtag or filler
if s == 0 && length(w) == 7
  htag = w;
else
  htag = 'xxxxxxx';
end

