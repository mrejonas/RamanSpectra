function z=LEGEND_C(y,n,ord,s)
N=length(n);
[n,i]=sort(n);
y=y(i);
maxy=max(y);
dely=(maxy-min(y))/2;
n=2*(n(:)-n(N))/(n(N)-n(1))+1;
y=(y(:)-maxy)/dely+1;
p=0:ord;
T=repmat(n,1,ord+1) .^ repmat(p,N,1);
Tinv=pinv(T'*T)*T';
a=Tinv*y;
z=T*a;
alpha=0.99*1/2;     % Scale parameter alpha
it=0;                 % Iteration number
zp=ones(N,1);         % Previous estimation
d=zeros(N,1);
while sum((z-zp).^2)/sum(zp.^2) > 1e-9
    it=it+1;        % Iteration number
    zp=z;             % Previous estimation
    res=y-z;        % Residual
    for num=1:N
        if res(num)<s
            d(num)=res(num)*(2*alpha-1);
        else if res(num)>=s
            d(num)=-res(num)-alpha*(s^3)/(2*res(num)*res(num));
            end
        end
    end
    a=Tinv*(y+d);   % Polynomial coefficients a
    z=T*a;
end
[~,j]=sort(i);
z=(z(j)-1)*dely+maxy;
end
