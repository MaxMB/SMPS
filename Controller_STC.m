% RLS filter
w_RLS = zeros(1,M); % RLS coef
e2_RLS = zeros(1,N); % RLS square error
R_inv = (1/del_RLS) * eye(M);
for j = 1:N
    if (j > M)
        x = flip(u((j-M+1):j));
    else
        x = [flip(u(1:j)); zeros(M-j,1)];
    end
    k_tilde = R_inv * x;
    gamma_tilde = 1 / (lambda_RLS + x' * k_tilde);
    k = gamma_tilde * k_tilde;
    y = w_RLS * x;
    e = d(j) - y;
    w_RLS = w_RLS + e * k';
    R_inv = (R_inv - gamma_tilde * (k_tilde * k_tilde')) / lambda_RLS;
    e2_RLS(j) = e^2;
end