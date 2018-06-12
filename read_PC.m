filename = 'Dataset_test_PC';
sheet = 'Quarterly';
range = 'B2:DA300';
do_truncation = 1; %Do truncate data.
[dataset, var_names] = read_data2(filename, sheet, range, do_truncation);
dataset = real(dataset);

pc = get_principal_components(dataset);

hold on
for i=1:5
      plot(pc(:,i))
end