function e=error1(a,EEG1,n,N,P,Th2)
for i=n-N:n+N    
   for k=2:P
   s(k)=(a(k)*EEG1(i-k));
   end
   e(i)=sum(s);
%    if abs(e(i))>=Th2
%        e(i)=sign(e(i))*Th2;
%    end
end
end