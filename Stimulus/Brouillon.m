tic()
IdxTxt = mod(i,nbTxt);
  if IdxTxt == 0
  Screen('DrawTexture', Window1, TextureSinus(nbTxt));
  else  
  Screen('DrawTexture', Window1, TextureSinus(IdxTxt));
  end
%TextureSinus = Screen(Window1, 'MakeTexture', PixVal(t(i))*ones(width,height));
%Screen('DrawTexture', Window1, TextureSinus(i));
Screen(Window1,'Flip')
A=toc()