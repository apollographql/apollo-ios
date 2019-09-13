export interface TableColumn {
    key: string;
    label?: string | (() => string);
    format(value: string, row: string): string;
    get(row: any[]): string;
    width: number;
}
export interface TableOptions {
    columns: Partial<TableColumn>[];
    colSep: string;
    after(row: any[], options: TableOptions): void;
    printLine(row: any[]): void;
    printRow(row: any[]): void;
    printHeader(row: any[]): void;
    headerAnsi: any;
}
/**
 * Generates a Unicode table and feeds it into configured printer.
 *
 * Top-level arguments:
 *
 * @arg {Object[]} data - the records to format as a table.
 * @arg {Object} options - configuration for the table.
 *
 * @arg {Object[]} [options.columns] - Options for formatting and finding values for table columns.
 * @arg {function(string)} [options.headerAnsi] - Zero-width formattter for entire header.
 * @arg {string} [options.colSep] - Separator between columns.
 * @arg {function(row, options)} [options.after] - Function called after each row is printed.
 * @arg {function(string)} [options.printLine] - Function responsible for printing to terminal.
 * @arg {function(cells)} [options.printHeader] - Function to print header cells as a row.
 * @arg {function(cells)} [options.printRow] - Function to print cells as a row.
 *
 * @arg {function(row)|string} [options.columns[].key] - Path to the value in the row or function to retrieve the pre-formatted value for the cell.
 * @arg {function(string)} [options.columns[].label] - Header name for column.
 * @arg {function(string, row)} [options.columns[].format] - Formatter function for column value.
 * @arg {function(row)} [options.columns[].get] - Function to return a value to be presented in cell without formatting.
 *
 */
export default function table(data: any[], inputOptions?: Partial<TableOptions>): void;
