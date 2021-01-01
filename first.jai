#import "Basic";
#import "Compiler";
#import "File";

OutputDir :: "builds/";

build :: (file: string) {
    #if #run (compiler_get_current_workspace() != 1) return;

    build_options := get_build_options();
    build_options.output_type = Build_Output_Type.NO_OUTPUT;
    set_build_options(build_options);

    w := compiler_create_workspace();

    build_options.output_type = Build_Output_Type.EXECUTABLE;
    build_options.output_executable_name = "gb-emulator";
    build_options.output_path = OutputDir;

    make_directory_if_it_does_not_exist(OutputDir);

    //build_options.array_bounds_check = Array_Bounds_Check_Mode.OFF;
    //build_options.emit_debug_info = Debug_Info_Type.NONE;
    //build_options.cast_bounds_check = Cast_Bounds_Check_Mode.OFF;
    //build_options.math_bounds_check = Cast_Bounds_Check_Mode.OFF;

    set_optimization_level(*build_options, 3, 2);
    set_build_options(build_options, w);

    add_build_file("src/main.jai", w);
}
#run build(#file);