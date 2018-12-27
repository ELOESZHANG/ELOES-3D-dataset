function [f,c2]=cv(Img,iternum)
[ny,nx]=size(Img);
 maximun=max(Img(:)) ;
[row,column]=find(Img==maximun);
locrow=ceil(length(row)/2);
loccol=ceil(length(column)/2);
c_i=(row(locrow));
c_j=(column(loccol));
r=c_i/3;
for i=1:ny
    for j=1:nx
        u(i,j)=r-sqrt((i-c_i).^2+(j-c_j).^2);
    end
end
epsilon=1.0;
mu=250;
dt=0.1;
nn=0;
for n=1:iternum
    H_u=0.5+1/pi.*atan(u/epsilon);
    c1=sum(sum((1-H_u).*Img))/sum(sum(1-H_u));
    c2=sum(sum(H_u.*Img))/sum(sum(H_u));
    delta_epsilon=1/pi*epsilon/(pi^2+epsilon^2);
    m=dt*delta_epsilon;
    C1=1./sqrt(eps+(u(:,[2:nx,nx])-u).^2+0.25*(u([2:ny,ny],:)-u([1,1:ny-1],:)).^2);
    C2=1./sqrt(eps+(u-u(:,[1,1:nx-1])).^2+0.25*(u([2:ny,ny],[1,1:nx-1])-u([1,1:ny-1],[1,1:nx-1])).^2);
    C3=1./sqrt(eps+(u([2:ny,ny],:)-u).^2+0.25*(u([2:ny,ny],[2:nx,nx])-u([2:ny,ny],[1,1:nx-1])).^2);
    C4=1./sqrt(eps+(u-u([1,1:ny-1],:)).^2+0.25*(u([1,1:ny-1],[2:nx,nx])-u([1,1:ny-1],[1,1:nx-1])).^2);
    C=1+mu*m.*(C1+C2+C3+C4);
    u=(u+m*(mu*(C1.*u(:,[2:nx,nx])+C2.*u(:,[1,1:nx-1])+C3.*u([2:ny,ny],:)+C4.*u([1,1:ny-1],:))+(Img-c1).^2-(Img-c2).^2))./C;
    nn=nn+1;
    f=Img;
    f(u>0)=c2;
    f(u<0)=c1;   
end
end
