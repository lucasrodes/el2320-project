function maximum_density = KDE(S, im_size)
    A = zeros(im_size);
    A(S(1,:),S(2,:)) = 1;
tic
    H = fspecial('Gaussian',[5 5],10);
    Out = imfilter(A,H,'same');
toc
    [maxA,ind] = max(Out(:));
    [m,n] = ind2sub(size(Out),ind);
    maximum_density = [m,n];
end